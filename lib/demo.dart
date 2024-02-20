// import 'package:flutter/material.dart';
//
// class Student {
//   String name;
//   int age;
//   String address;
//
//   Student({required this.name, required this.age, required this.address});
// }
//
// class UpdateStudentDetails extends StatefulWidget {
//   @override
//   _UpdateStudentDetailsState createState() => _UpdateStudentDetailsState();
// }
//
// class _UpdateStudentDetailsState extends State<UpdateStudentDetails> {
//   late TextEditingController _nameController;
//   late TextEditingController _ageController;
//   late TextEditingController _addressController;
//
//   // Mock student data
//   Student _student = Student(name: 'John Doe', age: 20, address: '123 Main St');
//
//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: _student.name);
//     _ageController = TextEditingController(text: _student.age.toString());
//     _addressController = TextEditingController(text: _student.address);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Update Student Details'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             _showUpdateDialog(context);
//           },
//           child: Text('Update Student'),
//         ),
//       ),
//     );
//   }
//
//   void _showUpdateDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Update Student Details'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: _nameController,
//                 decoration: InputDecoration(labelText: 'Name'),
//               ),
//               TextField(
//                 controller: _ageController,
//                 decoration: InputDecoration(labelText: 'Age'),
//                 keyboardType: TextInputType.number,
//               ),
//               TextField(
//                 controller: _addressController,
//                 decoration: InputDecoration(labelText: 'Address'),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 _resetFields();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Reset'),
//             ),
//             TextButton(
//               onPressed: () {
//                 _updateStudentDetails();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Submit'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _resetFields() {
//     _nameController.text = _student.name;
//     _ageController.text = _student.age.toString();
//     _addressController.text = _student.address;
//   }
//
//   void _updateStudentDetails() {
//     setState(() {
//       _student.name = _nameController.text;
//       _student.age = int.tryParse(_ageController.text) ?? 0;
//       _student.address = _addressController.text;
//     });
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _ageController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }
// }
//
// void main() {
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: UpdateStudentDetails(),
//   ));
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

class Student {
  final String name;
  final String program;
  final String programTerm;
  final String division;

  Student(
      {required this.name,
      required this.program,
      required this.programTerm,
      required this.division});

  // Convert Student object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'program': program,
      'programTerm': programTerm,
      'division': division,
    };
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add student to Firestore
  Future<void> addStudent(Student student) async {
    try {
      await _firestore
          .collection('student')
          .doc(student.program)
          .collection(student.programTerm)
          .doc(student.division)
          .collection('student')
          .doc(student.name)
          .set(student.toMap());
    } catch (e) {
      print('Error adding student: $e');
    }
  }

  // Fetch students from Firestore based on program, program term, and division
  Stream<List<Student>> getStudents(
      String program, String programTerm, String division) {
    return _firestore
        .collection('student')
        .doc(program)
        .collection(programTerm)
        .doc(division)
        .collection('student')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Student(
                  name: doc['name'],
                  program: doc['program'],
                  programTerm: doc['programTerm'],
                  division: doc['division'],
                ))
            .toList());
  }
}

class AddStudentPage extends StatelessWidget {
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    //  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: SystemUiOverlay.values);
  }
  final TextEditingController nameController = TextEditingController();
  final TextEditingController programController = TextEditingController();
  final TextEditingController programTermController = TextEditingController();
  final TextEditingController divisionController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Student'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: programController,
              decoration: InputDecoration(labelText: 'Program'),
            ),
            TextField(
              controller: programTermController,
              decoration: InputDecoration(labelText: 'Program Term'),
            ),
            TextField(
              controller: divisionController,
              decoration: InputDecoration(labelText: 'Division'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Student newStudent = Student(
                  name: nameController.text,
                  program: programController.text,
                  programTerm: programTermController.text,
                  division: divisionController.text,
                );
                _firestoreService.addStudent(newStudent);
                Navigator.pop(context); // Navigate back after adding student
              },
              child: Text('Add Student'),
            ),
          ],
        ),
      ),
    );
  }
}

class DisplayStudentsPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students'),
      ),
      body: StreamBuilder<List<Student>>(
        stream: _firestoreService.getStudents('BCA', 'Sem-3', 'C'),
        // Example program, program term, and division
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text('No students found'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data![index].name),
                subtitle: Text(
                    'Program: ${snapshot.data![index].program}, Term: ${snapshot.data![index].programTerm}, Division: ${snapshot.data![index].division}'),
              );
            },
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => AddStudentPage(),
      '/displayStudents': (context) => DisplayStudentsPage(),
    },
  ));
}
