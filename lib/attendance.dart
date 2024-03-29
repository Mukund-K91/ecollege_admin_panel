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
  final String middlename;
  final String lastname;
  final int rollNumber;

  Student(
      {required this.documentId,
      required this.userID,
      required this.firstname,
        required this.middlename,
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
  final String program;

  const Attendance({required this.program});

  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  List<Student> students = [];
  String selectedSubject = '--Please Select--'; // Default subject
  DateTime selectedDate = DateTime.now();

  List<AttendanceRecord> attendanceRecords = [];
  String selectedProgram="BCA";
  String selectedProgramTerm = "--Please Select--";
  String selectedDivision = "--Please Select--";
  String searchQuery = '';
  List<String> subjectList = [];

  @override
  void initState() {
    super.initState();
    selectedProgram = widget.program;
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
        .orderBy('Last Name')
        .get();

    students = studentsQuery.docs.map((doc) {
      return Student(
          documentId: doc.id,
          userID: doc['User Id'],
          firstname: doc['First Name'],
          middlename: doc['Middle Name'],
          rollNumber: doc['rollNumber']??null,
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

  void updateSubjectList(String Program, String ProgramTerm) {
    // Get the subject list based on the selected program and program term
    subjectList = SubjectLists.getSubjects(Program, ProgramTerm);
    setState(() {
      //selectedSubject = subjectList.isNotEmpty ? subjectList[0] : null;
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

      CollectionReference AttendanceCollection =
          studentDocRef.collection('yearlyAttendance');

      String Year = DateFormat('yyyy').format(selectedDate);
      String monthYearKey = '${Year}';

      DocumentReference AttendanceDocRef =
          AttendanceCollection.doc(monthYearKey);

      DocumentSnapshot<Object?> monthlyAttendanceDoc =
          await AttendanceDocRef.get();

      if (!monthlyAttendanceDoc.exists) {
        // Create new monthly attendance record if not exists for the current month and year
        batch.set(AttendanceDocRef, {
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
        batch.update(AttendanceDocRef, {
          'subjectAttendance.$selectedSubject.presentCount':
              FieldValue.increment(1),
        });
      } else {
        // Increment absent count if the student is absent
        batch.update(AttendanceDocRef, {
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
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance Successfully added")));
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = students
        .where((student) =>
            student.firstname.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    final currentDate = DateFormat('dd-MM-yyyy EEEE').format(selectedDate);

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: double.infinity,
          height: 30,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff002233),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))),
              onPressed: () async {
                _submitAttendance(
                    selectedProgram, selectedProgramTerm, selectedDivision);
              },
              child: const Text(
                "SUBMIT",
                style: TextStyle(color: Colors.white, fontSize: 15),
              )),
        ),
      ),
      appBar: AppBar(
        title: Text('Attendance Stream: ${selectedProgram}',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ListTile(
                    title: const Text(
                      "Program Term",
                      style: TextStyle(fontSize: 15),
                    ),
                    subtitle: DropdownButtonFormField(
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.zero))),
                        value: selectedProgramTerm,
                        items: lists.programTerms
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedProgramTerm = val as String;
                            updateSubjectList(
                                selectedProgram, selectedProgramTerm);
                          });
                        }),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text(
                      "Division",
                      style: TextStyle(fontSize: 15),
                    ),
                    subtitle: DropdownButtonFormField(
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.zero))),
                        value: selectedDivision,
                        items: selectedProgram == "BCA"
                            ? lists.bcaDivision
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
                                : lists.bbaDivision
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedDivision = val as String;
                            fetchData(selectedProgram, selectedProgramTerm,
                                selectedDivision);
                          });
                        }),
                  ),
                ),
              ],
            ),
            ListTile(
              title: const Text(
                "Subject",
                style: TextStyle(fontSize: 15),
              ),
              subtitle: DropdownButtonFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.zero))),
                  value: selectedSubject,
                  items: subjectList
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedSubject = val as String;
                    });
                  }),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                Student student = filteredStudents[index];
                AttendanceRecord record = attendanceRecords[index];
                return Card(
                  child: ListTile(
                    leading: Text(
                      '${student.rollNumber}',
                      style: TextStyle(
                          color: Color(0xff002233),
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                    title: Text('${student.lastname} ${student.firstname} ${student.middlename}',style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold),),
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
                  ),
                );
              },
            ),
          ],
        ),
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
