

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

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

TextEditingController _totalMarks = TextEditingController();
TextEditingController _examName = TextEditingController();

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<Student> students = [];
  List<TextEditingController> obtainMarksControllers = [];
  String selectedProgram = "BCA";
  String selectedProgramTerm = "Sem - 6";
  String selectedDivision = "C";
  String selectedSubject = "--Please Select--";
  String searchQuery = '';
  String acYear = "23-24";
  List<String> subjectList = [];

  @override
  void initState() {
    super.initState();
    fetchData(selectedProgram, selectedProgramTerm, selectedDivision);
    _totalMarks.addListener(updateTotalMarks);
    obtainMarksControllers = List.generate(
      students.length,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    _totalMarks.removeListener(updateTotalMarks);
    // Dispose controllers
    obtainMarksControllers.forEach((controller) => controller.dispose());
    super.dispose();
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

    // Update obtain marks controllers
    setState(() {
      obtainMarksControllers = List.generate(
        students.length,
        (_) => TextEditingController(),
      );
    });
  }

  void updateSubjectList(String Program, String ProgramTerm) {
    // Get the subject list based on the selected program and program term
    subjectList = SubjectLists.getSubjects(Program, ProgramTerm);
    setState(() {
      selectedSubject =
          subjectList.isNotEmpty ? subjectList[0] : "--Please Select--";
    });
  }

  Future<void> addResult(
    String program,
    String programTerm,
    String division,
    String userId,
    String selectedSubject,
    int totalMarks,
    int obtainMarks,
    String examName,
  ) async {
    try {
      // Reference to the user's document
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('students')
          .doc(program)
          .collection(programTerm)
          .doc(division)
          .collection('student')
          .doc(userId)
          .collection('result')
          .doc(acYear);

      // Check if the exam name already exists in the database
      DocumentSnapshot examSnapshot = await userRef.get();
      Map<String, dynamic>? data = examSnapshot.data()
          as Map<String, dynamic>?; // Cast to Map<String, dynamic> or null
      if (data != null &&
          data['result'] != null &&
          data['result'][examName] != null) {
        // Exam name already exists, update subject result under that exam entry
        await userRef.update({
          'result.$examName.$selectedSubject': {
            'totalmarks': totalMarks,
            'obtainmarks': obtainMarks,
          },
        });
      } else {
        // Exam name does not exist, create a new entry
        await userRef.set({
          examName: {
            selectedSubject: {
              'totalmarks': totalMarks,
              'obtainmarks': obtainMarks,
            },
          },
        }, SetOptions(merge: true));
      }

      // Clear input fields and controllers
      _totalMarks.clear();
      obtainMarksControllers.forEach((controller) => controller.clear());

      // Show success message if all students' marks are added
      if (userId == students.last.userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marks added successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error adding result: $e');
    }
  }

  void updateTotalMarks() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = students
        .where((student) =>
            student.rollNo.toString().contains(searchQuery.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Result Page'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
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
              ),
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
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
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
                                        borderRadius:
                                            BorderRadius.all(Radius.zero))),
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
                        Expanded(
                          child: TextField(
                            controller: _examName,
                            decoration: InputDecoration(
                                hintText: "Exam Name",
                                label: Text("Exam Name")),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _totalMarks,
                            decoration: InputDecoration(
                                hintText: "00", label: Text("Total marks")),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      // Inside the DataTable, update the DataRows to properly access the obtain marks
                      rows: filteredStudents.map((student) {
                        int index = filteredStudents.indexOf(student);
                        return DataRow(cells: [
                          DataCell(Text('${student.userId}',
                              style: TextStyle(fontSize: 20))),
                          DataCell(Text('${student.rollNo}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold))),
                          DataCell(Text(
                              "${student.lastname} ${student.firstname} ${student.middlename}",
                              style: TextStyle(fontSize: 20))),
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.grey)),
                                width: 70,
                                height: 50,
                                child: Center(
                                  child: Text('${_totalMarks.text}',
                                      style: TextStyle(fontSize: 18)),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: SizedBox(
                                width: 60,
                                child: TextFormField(
                                  controller: obtainMarksControllers[index],
                                  // Associate controller with the corresponding student
                                  maxLength: 3,
                                  enableSuggestions: true,
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: "000",
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
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_totalMarks.text.isNotEmpty &&
              obtainMarksControllers.toString() != "") {
            for (int i = 0; i < filteredStudents.length; i++) {
              addResult(
                  selectedProgram,
                  selectedProgramTerm,
                  selectedDivision,
                  filteredStudents[i].userId,
                  selectedSubject,
                  int.tryParse(_totalMarks.text) ?? 0,
                  int.tryParse(obtainMarksControllers[i].text) ?? 0,
                  _examName
                      .text // Convert _obtainMarks.text to int, default to 0 if conversion fails
                  );
            }
            _totalMarks.clear();
            obtainMarksControllers.forEach((controller) => controller.clear());
          } else {
            print('Please enter total marks');
          }
        },
        child: Icon(Icons.save), // Icon for the floating action button
      ),
    );
  }
}
