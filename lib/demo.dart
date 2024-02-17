import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentEntryScreen extends StatefulWidget {
  @override
  _StudentEntryScreenState createState() => _StudentEntryScreenState();
}

class _StudentEntryScreenState extends State<StudentEntryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _studentsCollection;
  late DocumentReference _rollNumberDoc;

  int _lastRollNumber = 0;

  @override
  void initState() {
    super.initState();
    _studentsCollection = _firestore.collection('student');
    _rollNumberDoc = _firestore.collection('metadata').doc('rollNumber');
    _getRollNumber();
  }

  Future<void> _getRollNumber() async {
    final rollNumberDocSnapshot = await _rollNumberDoc.get();
    setState(() {
      _lastRollNumber =
          rollNumberDocSnapshot.exists && rollNumberDocSnapshot.data() != null
              ? (rollNumberDocSnapshot.data()
                      as Map<String, dynamic>)['lastRollNumber'] ??
                  0
              : 0;
    });
  }

  Future<void> _incrementRollNumber() async {
    _lastRollNumber++;
    await _rollNumberDoc.set({'lastRollNumber': _lastRollNumber});
  }

  Future<void> _addStudentEntry() async {
    await _studentsCollection.add({
      'rollNumber': _lastRollNumber,
      // Add other student details here
    });
    await _incrementRollNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Roll Number Generator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Last Generated Roll Number: $_lastRollNumber',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addStudentEntry,
              child: Text('Add Student Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
