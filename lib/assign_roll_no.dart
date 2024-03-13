import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      appBar: AppBar(
        title: Text('Assign Roll Numbers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedProgram.isEmpty ? null : _selectedProgram,
              onChanged: (value) {
                setState(() {
                  _selectedProgram = value!;
                  _selectedProgramTerm = '';
                  _selectedDivision = '';
                });
              },
              items: [
                '--Please Select--',
                'BCA',
                'B-Com',
                'BBA',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Program'),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedProgramTerm.isEmpty ? null : _selectedProgramTerm,
              onChanged: (value) {
                setState(() {
                  _selectedProgramTerm = value!;
                  _selectedDivision = '';
                });
              },
              items: [
                if (_selectedProgram == 'BCA') ...[
                  '--Please Select--',
                  'Sem - 1',
                  'Sem - 2',
                  'Sem - 3',
                  'Sem - 4',
                  'Sem - 5',
                  'Sem - 6',
                ],
                if (_selectedProgram == 'B-Com' || _selectedProgram == 'BBA') ...[
                  '--Please Select--',
                  'Semester 1',
                  'Semester 2',
                  'Semester 3',
                  'Semester 4',
                  'Semester 5',
                  'Semester 6',
                ],
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Program Term'),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedDivision.isEmpty ? null : _selectedDivision,
              onChanged: (value) {
                setState(() {
                  _selectedDivision = value!;
                  _fetchStudents();
                });
              },
              items: [
                '--Please Select--',
                'A',
                'B',
                'C',
                'D',
                'E',
                'F',
                'G',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Division'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot student = _students[index];
                  return ListTile(
                    title: Text(student['First Name'] + ' ' + student['Last Name']),
                    subtitle: Text(student['User Id']),
                    trailing: Text('Roll Number: ${index + 1}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _assignRollNumbers();
              },
              child: Text('Assign Roll Numbers'),
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
        .collection('student')
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