import 'package:ecollege_admin_panel/reusable_widget/lists.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RollNumberAssignment(),
    );
  }
}

class RollNumberAssignment extends StatefulWidget {
  @override
  _RollNumberAssignmentState createState() => _RollNumberAssignmentState();
}

class _RollNumberAssignmentState extends State<RollNumberAssignment> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _students = [];
  String _selectedProgram = '';
  String _selectedProgramTerm = '';
  String _selectedDivision = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:  Padding(
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
               _assignRollNumbers();
              },
              child: const Text(
                "Assign",
                style: TextStyle(color: Colors.white, fontSize: 15),
              )),
        ),
      ),
      appBar: AppBar(
        title: Text('Assign Roll Numbers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedProgram.isEmpty ? null : _selectedProgram,
                    onChanged: (value) {
                      setState(() {
                        _selectedProgram = value!;
                        _selectedProgramTerm = '';
                        _selectedDivision = '';
                      });
                    },
                    items: lists.programs.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Program'),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedProgramTerm.isEmpty ? null : _selectedProgramTerm,
                    onChanged: (value) {
                      setState(() {
                        _selectedProgramTerm = value!;
                        _selectedDivision = '';
                      });
                    },
                    items:lists.programTerms.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Program Term'),
                  ),
                ),
                SizedBox(width: 16.0),
               Expanded(child:  DropdownButtonFormField<String>(
                 value: _selectedDivision.isEmpty ? null : _selectedDivision,
                 onChanged: (value) {
                   setState(() {
                     _selectedDivision = value!;
                     _fetchStudents();
                   });
                 },
                 items:  _selectedProgram == "BCA"
                     ? lists.bcaDivision
                     .map((e) => DropdownMenuItem(
                   value: e,
                   child: Text(e),
                 ))
                     .toList()
                     : _selectedProgram == "B-Com"
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
                 decoration: InputDecoration(labelText: 'Division'),
               ),),
              ],
            ),
            SizedBox(height: 15,),
            Expanded(
              child: ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot student = _students[index];
                  return Card(
                    child: ListTile(
                      title: Text('${student['Last Name']} ${student['First Name']} ${student['Middle Name']}',style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold),),
                      subtitle: Text('${student['User Id']}'),
                      trailing:Text('Roll No. : ${index+1}',style: TextStyle(fontSize: 15),)
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchStudents() async {
    QuerySnapshot snapshot = await _firestore
        .collection('students')
        .doc(_selectedProgram)
        .collection(_selectedProgramTerm)
        .doc(_selectedDivision)
        .collection('student').orderBy('Last Name')
        .get();
    setState(() {
      _students = snapshot.docs;
    });
  }

  Future<void> _assignRollNumbers() async {
    WriteBatch batch = _firestore.batch();
    for (int i = 0; i < _students.length; i++) {
      DocumentSnapshot student = _students[i];
      batch.update(student.reference, {'rollNumber': i + 1});
    }
    await batch.commit();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Roll Numbers Assigned'),
          content: Text('Roll numbers have been assigned successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
