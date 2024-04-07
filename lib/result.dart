import 'package:ecollege_admin_panel/reusable_widget/lists.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String userId;
  final String firstName;
  int totalMarks = 0;
  int obtainMarks = 0;

  Student({
    required this.userId,
    required this.firstName,
  });
}

class StudentResultTable extends StatefulWidget {
  @override
  _StudentResultTableState createState() => _StudentResultTableState();
}

class _StudentResultTableState extends State<StudentResultTable> {
  String selectedProgram = "--Please Select--";
  String selectedProgramTerm = "--Please Select--";
  String selectedDivision = "--Please Select--";
  String selectedSubject = "--Please Select--";
  String selectedExam = "--Please Select--";

  List<String> subjectList = [];
  List<Student> studentList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  void updateSubjectList(String Program, String ProgramTerm) {
    // Get the subject list based on the selected program and program term
    subjectList = SubjectLists.getSubjects(Program, ProgramTerm);
    setState(() {
      selectedSubject =
          subjectList.isNotEmpty ? subjectList[0] : "--Please Select--";
    });
  }

  Future<void> fetchStudentData() async {
    try {
      setState(() {
        isLoading = true;
      });

      QuerySnapshot<Map<String, dynamic>> studentSnapshot =
          await FirebaseFirestore.instance
              .collection('students')
              .doc(selectedProgram)
              .collection(selectedProgramTerm)
              .doc(selectedDivision)
              .collection('student')
              .get();

      studentList.clear(); // Clear existing list before fetching new data

      studentSnapshot.docs.forEach((doc) {
        studentList.add(Student(
          userId: doc.id,
          firstName: doc['First Name'],
        ));
      });

      await Future.forEach(studentList, (Student student) async {
        await fetchData(student);
      });

      setState(() {
        isLoading = false;
      }); // Update the UI after fetching data
    } catch (e) {
      print('Error fetching student data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchData(Student student) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> resultSnapshot =
      await FirebaseFirestore.instance
          .collection('students')
          .doc(selectedProgram)
          .collection(selectedProgramTerm)
          .doc(selectedDivision)
          .collection('student')
          .doc(student.userId)
          .collection('result')
          .doc('23-24')
          .get();

      Map<String, dynamic> resultData = resultSnapshot.data() ?? {};

      if (resultData.containsKey('Practical-Internal')) {
        final practicalInternalData = resultData['Practical-Internal'];
        if (practicalInternalData.containsKey('PROJECT')) {
          final projectData = practicalInternalData['PROJECT'];
          student.totalMarks = projectData['totalmarks'] ?? 0;
          student.obtainMarks = projectData['obtainmarks'] ?? 0;
        }
      }
    } catch (e) {
      print('Error fetching result data for student ${student.userId}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Result Table'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dropdowns for selecting program, term, division, subject, and exam
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text(
                      "Program",
                      style: TextStyle(fontSize: 15),
                    ),
                    subtitle: DropdownButtonFormField(
                        isExpanded: true,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.zero))),
                        value: selectedProgram,
                        items: lists.programs
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedProgram = val as String;
                          });
                        }),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text(
                      "Program Term",
                      style: TextStyle(fontSize: 15),
                    ),
                    subtitle: DropdownButtonFormField(
                        isExpanded: true,
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
                        isExpanded: true,
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
                          });
                        }),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text(
                      "Exam Type",
                      style: TextStyle(fontSize: 15),
                    ),
                    subtitle: DropdownButtonFormField(
                        isExpanded: true,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.zero))),
                        value: selectedExam,
                        items: [
                          '--Please Select--',
                          'Internal',
                          'Practical-Internal'
                        ]
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedExam = val as String;
                          });
                        }),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text(
                      "Subject",
                      style: TextStyle(fontSize: 15),
                    ),
                    subtitle: DropdownButtonFormField(
                        isExpanded: true,
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
                            fetchStudentData();
                          });
                        }),
                  ),
                ),
              ],
            ),
            isLoading
                ? CircularProgressIndicator() // Show loading indicator while fetching data
                : studentList.isEmpty
                    ? Center(
                        child: Text(
                            'No Data Found'), // Show "No Data Found" if student list is empty
                      )
                    : DataTable(
                        columns: const <DataColumn>[
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Total Marks')),
                          DataColumn(label: Text('Obtain Marks')),
                        ],
                        rows: studentList.map((student) {
                          return DataRow(cells: <DataCell>[
                            DataCell(Text(student.firstName)),
                            DataCell(Text(student.totalMarks.toString())),
                            DataCell(Text(student.obtainMarks.toString())),
                          ]);
                        }).toList(),
                      ),
          ],
        ),
      ),
    );
  }
}
