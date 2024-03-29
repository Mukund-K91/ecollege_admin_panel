import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../reusable_widget/lists.dart';
import '../reusable_widget/reusable_textfield.dart';

class Student {
  final String firstname;
  final String middlename;
  final String lastname;
  final String userId;
  final int rollNo;

  Student({
    required this.firstname,
    required this.middlename,
    required this.lastname,
    required this.userId,
    required this.rollNo,
  });
}

TextEditingController _obtainMarks = TextEditingController();
TextEditingController _totalMarks = TextEditingController();

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<Student> students = [];
  String selectedProgram = "BCA";
  String selectedProgramTerm = "Sem - 6";
  String selectedDivision = "C";
  String selectedSubject = "--Please Select--";
  String searchQuery = '';
  List<String> subjectList = [];

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
        .orderBy('Last Name')
        .get();

    students = studentsQuery.docs.map((doc) {
      return Student(
        firstname: doc['First Name'],
        middlename: doc['Middle Name'],
        lastname: doc['Last Name'],
        userId: doc['User Id'],
        rollNo: doc['rollNumber'],
      );
    }).toList();

    setState(() {});
  }

  void updateSubjectList(String Program, String ProgramTerm) {
    // Get the subject list based on the selected program and program term
    subjectList = SubjectLists.getSubjects(Program, ProgramTerm);
    setState(() {
      selectedSubject =
          subjectList.isNotEmpty ? subjectList[0] : "--Please Select--";
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = students
        .where((student) =>
            student.rollNo.toString().contains(searchQuery.toLowerCase()))
        .toList();
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ReusableTextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              title: 'Search By Name',
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
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
                                    borderRadius:
                                        BorderRadius.all(Radius.zero))),
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
                                fetchData(selectedProgram, selectedProgramTerm,
                                    selectedDivision);
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
                                    borderRadius:
                                        BorderRadius.all(Radius.zero))),
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
                                selectedSubject = "--Please Select--";
                                fetchData(selectedProgram, selectedProgramTerm,
                                    selectedDivision);
                                updateSubjectList(selectedProgram.toString(),
                                    selectedProgramTerm.toString());
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
                                    borderRadius:
                                        BorderRadius.all(Radius.zero))),
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
                    )
                  ],
                ),
                Row(children: [
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
                            });
                          }),
                    ),
                  ),
                  Expanded(child: TextField(decoration: InputDecoration(label: Text("Total marks")),)),
                ],),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: DataTable(
                    columnSpacing: 50,
                    border: TableBorder.all(),
                    columns: const [
                      DataColumn(label: Text('User Id')),
                      DataColumn(label: Text('Roll No')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Total')),
                      DataColumn(label: Text('Obtain')),
                    ],
                    rows: filteredStudents
                        .map(
                          (student) => DataRow(cells: [
                            DataCell(Text(
                              '${student.userId}',
                              style: TextStyle(fontSize: 20),
                            )),
                            DataCell(Text('${student.rollNo}',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold))),
                            DataCell(Text(
                                "${student.lastname} ${student.firstname} ${student.middlename}",
                                style: TextStyle(fontSize: 20))),
                            DataCell(Padding(
                              padding: const EdgeInsets.all(5),
                              child: SizedBox(
                                width: 60,
                                child: TextFormField(
                                  maxLength: 3,
                                  enableSuggestions: true,
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    counterText: "",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value != null) {
                                      int? totalMarks =
                                          int.tryParse(_totalMarks.text);
                                      int? obtainMarks = int.tryParse(value);
                                      if (totalMarks == null ||
                                          obtainMarks == null) {
                                        return 'Enter valid marks';
                                      }
                                      if (obtainMarks > totalMarks) {
                                        return 'Obtain marks should not be greater than total marks';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            )),
                            DataCell(Padding(
                              padding: const EdgeInsets.all(5),
                              child: SizedBox(
                                width: 60,
                                child: TextFormField(
                                  maxLength: 3,
                                  enableSuggestions: true,
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    counterText: "",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value != null) {
                                      int? totalMarks =
                                          int.tryParse(_totalMarks.text);
                                      int? obtainMarks = int.tryParse(value);
                                      if (totalMarks == null ||
                                          obtainMarks == null) {
                                        return 'Enter valid marks';
                                      }
                                      if (obtainMarks > totalMarks) {
                                        return 'Obtain marks should not be greater than total marks';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            )),
                          ]),
                        )
                        .toList(),
                  ),
                ),
                SizedBox(
                  height: 30,
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}
