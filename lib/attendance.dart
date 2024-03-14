import 'package:ecollege_admin_panel/reusable_widget/lists.dart';
import 'package:ecollege_admin_panel/reusable_widget/reusable_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Student {
  final String documentId; // Firestore document ID
  final String userID;
  final String firstname;
  final String lastname;
  final int rollNumber;

  Student(
      {required this.documentId,
      required this.userID,
      required this.firstname,
      required this.lastname,
      required this.rollNumber});
}

class AttendanceRecord {
  final String subject;
  bool isPresent;

  AttendanceRecord({
    required this.subject,
    this.isPresent = true, // Default isPresent to true (present)
  });
}

class Attendance extends StatefulWidget {
  final program;

  const Attendance({super.key, this.program});

  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  List<Student> students = [];
  String selectedSubject = '--Please Select--'; // Default subject
  DateTime selectedDate = DateTime.now();

  List<AttendanceRecord> attendanceRecords = [];
  String selectedProgram = '--Please Select--';
  String selectedProgramTerm = "--Please Select--";
  String selectedDivision = "--Please Select--";
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchData(selectedProgram, selectedProgramTerm, selectedDivision);
  }

  Future<void> fetchData(
      String program, String programTerm, String division) async {
    QuerySnapshot<Map<String, dynamic>> studentsQuery = await FirebaseFirestore
        .instance
        .collection('students')
        .doc(program)
        .collection(programTerm)
        .doc(division)
        .collection('student')
        .orderBy('User Id')
        .get();

    students = studentsQuery.docs.map((doc) {
      return Student(
          documentId: doc.id,
          userID: doc['User Id'],
          firstname: doc['First Name'],
          rollNumber: doc['rollNumber'],
          lastname: doc['Last Name']);
    }).toList();

    // Initialize attendanceRecords with default values
    attendanceRecords = students.map((student) {
      return AttendanceRecord(subject: selectedSubject);
    }).toList();

    setState(() {});
  }

  void _toggleAttendance(int index) {
    setState(() {
      // Toggle the isPresent status for the student at the given index
      attendanceRecords[index].isPresent = !attendanceRecords[index].isPresent;
    });
  }

  Future<void> _submitAttendance(
      String program, String programTerm, String division) async {
    CollectionReference studentCollection =
        FirebaseFirestore.instance.collection('students');

    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (int i = 0; i < students.length; i++) {
      Student student = students[i];

      // Create or update monthly attendance subcollection
      DocumentReference studentDocRef = studentCollection
          .doc(program)
          .collection(programTerm)
          .doc(division)
          .collection('student')
          .doc(student.documentId);

      CollectionReference monthlyAttendanceCollection =
          studentDocRef.collection('monthlyAttendance');

      String monthYear = DateFormat('MMMM_yyyy').format(selectedDate);
      String monthYearKey = '${monthYear}';

      DocumentReference monthlyAttendanceDocRef =
          monthlyAttendanceCollection.doc(monthYearKey);

      DocumentSnapshot<Object?> monthlyAttendanceDoc =
          await monthlyAttendanceDocRef.get();

      if (!monthlyAttendanceDoc.exists) {
        // Create new monthly attendance record if not exists for the current month and year
        batch.set(monthlyAttendanceDocRef, {
          'subjectAttendance': {
            selectedSubject: {
              'presentCount': 0,
              'absentCount': 0,
            }
          },
        });
      }

      // Update monthly attendance count based on the recorded counts
      AttendanceRecord record = attendanceRecords[i];
      if (record.isPresent) {
        // Increment present count if the student is present
        batch.update(monthlyAttendanceDocRef, {
          'subjectAttendance.$selectedSubject.presentCount':
              FieldValue.increment(1),
        });
      } else {
        // Increment absent count if the student is absent
        batch.update(monthlyAttendanceDocRef, {
          'subjectAttendance.$selectedSubject.absentCount':
              FieldValue.increment(1),
        });
      }
    }

    // Commit the batch
    await batch.commit();

    // Reset attendanceRecords after submitting
    setState(() {
      attendanceRecords = students.map((student) {
        return AttendanceRecord(subject: selectedSubject);
      }).toList();
    });

    print(
        'Attendance submitted for date: $selectedDate, subject: $selectedSubject');
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = students
        .where((student) =>
            student.firstname.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    final currentDate = DateFormat('dd-MM-yyyy EEEE').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Attendance', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${currentDate}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ReusableTextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  title: 'Search By Name',
                ),
              ),
              DropdownButton<String>(
                value: selectedProgram,
                onChanged: (String? value) {
                  setState(() {
                    selectedProgram = value!;
                    selectedProgramTerm = '--Please Select--';
                    fetchData(
                        selectedProgram, selectedProgramTerm, selectedDivision);
                  });
                },
                items: lists.programs.map<DropdownMenuItem<String>>(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
                hint: const Text('Program'),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: selectedProgramTerm,
                onChanged: (String? value) {
                  setState(() {
                    selectedProgramTerm = value!;
                    fetchData(
                        selectedProgram, selectedProgramTerm, selectedDivision);
                  });
                },
                items: selectedProgram == '--Please Select--'
                    ? []
                    : lists.programTerms.map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                hint: const Text('Program Term'),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: selectedDivision,
                onChanged: (String? value) {
                  setState(() {
                    selectedDivision = value!;
                    fetchData(
                        selectedProgram, selectedProgramTerm, selectedDivision);
                  });
                },
                items: selectedProgramTerm == '--Please Select--'
                    ? []
                    : selectedProgram == "BCA"
                        ? lists.bbaDivision
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList()
                        : selectedProgram == "B-Com"
                            ? lists.bcomDivision
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList()
                            : lists.bcomDivision
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                hint: const Text('Class'),
              ),
              DropdownButton<String>(
                value: selectedSubject,
                onChanged: (String? value) {
                  setState(() {
                    selectedSubject = value!;
                  });
                },
                items: lists.bca_sem6.map<DropdownMenuItem<String>>(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
                hint: const Text('Class'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                Student student = filteredStudents[index];
                AttendanceRecord record = attendanceRecords[index];
                return ListTile(
                  leading: Text('${student.rollNumber}'),
                  title: Text('${student.firstname} ${student.lastname}'),
                  subtitle: Text('${student.userID}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor:
                          record.isPresent ? Colors.green : Colors.red,
                      minimumSize: Size(100, 40),
                    ),
                    onPressed: () {
                      _toggleAttendance(index);
                    },
                    child: Text(
                      record.isPresent ? 'Present' : 'Absent',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _submitAttendance(
                  selectedProgram, selectedProgramTerm, selectedDivision);
            },
            child: Text('Submit Attendance'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }
}
