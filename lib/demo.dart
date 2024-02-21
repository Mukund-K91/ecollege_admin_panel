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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String program;
  final String programTerm;
  final String division;

  Student({
    required this.id,
    required this.name,
    required this.program,
    required this.programTerm,
    required this.division,
  });

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
          .collection('students')
          .doc(student.program)
          .collection(student.programTerm)
          .doc(student.division)
          .collection('students')
          .doc(student.id)
          .set(student.toMap());
    } catch (e) {
      print('Error adding student: $e');
    }
  }

  // Fetch students from Firestore based on program, program term, and division
  Stream<List<Student>> getStudents(
      String program, String programTerm, String division) {
    return _firestore
        .collection('students')
        .doc(program)
        .collection(programTerm)
        .doc(division)
        .collection('students')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Student(
      id: doc.id,
      name: doc['name'],
      program: doc['program'],
      programTerm: doc['programTerm'],
      division: doc['division'],
    ))
        .toList());
  }

  // Search students by name
  Stream<List<Student>> searchStudents(String program, String programTerm,
      String division, String searchTerm) {
    return _firestore
        .collection('students')
        .doc(program)
        .collection(programTerm)
        .doc(division)
        .collection('students')
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThanOrEqualTo: searchTerm + '\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Student(
      id: doc.id,
      name: doc['name'],
      program: doc['program'],
      programTerm: doc['programTerm'],
      division: doc['division'],
    ))
        .toList());
  }
}

class StudentListScreen extends StatefulWidget {
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late String _selectedProgram;
  late String _selectedProgramTerm;
  late String _selectedDivision;
  late String _searchTerm;

  @override
  void initState() {
    super.initState();
    _selectedProgram = '';
    _selectedProgramTerm = '';
    _selectedDivision = '';
    _searchTerm = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student List'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildStudentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          DropdownButton<String>(
            value: _selectedProgram,
            onChanged: (String? value) {
              setState(() {
                _selectedProgram = value!;
              });
            },
            items: ['BCA', 'BBA', 'BCom']
                .map<DropdownMenuItem<String>>(
                  (String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ),
            )
                .toList(),
            hint: Text('Program'),
          ),
          SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedProgramTerm,
            onChanged: (String? value) {
              setState(() {
                _selectedProgramTerm = value!;
              });
            },
            items: ['Sem-1', 'Sem-2', 'Sem-3', 'Sem-4']
                .map<DropdownMenuItem<String>>(
                  (String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ),
            )
                .toList(),
            hint: Text('Program Term'),
          ),
          SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedDivision,
            onChanged: (String? value) {
              setState(() {
                _selectedDivision = value!;
              });
            },
            items: ['A', 'B', 'C']
                .map<DropdownMenuItem<String>>(
                  (String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ),
            )
                .toList(),
            hint: Text('Division'),
          ),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search by name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchTerm = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    return StreamBuilder<List<Student>>(
      stream: _searchTerm.isEmpty
          ? _firestoreService.getStudents(
          _selectedProgram, _selectedProgramTerm, _selectedDivision)
          : _firestoreService.searchStudents(
          _selectedProgram, _selectedProgramTerm, _selectedDivision, _searchTerm),
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

        final students = snapshot.data;

        if (students == null || students.isEmpty) {
          return Center(
            child: Text('No students found'),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Program')),
              DataColumn(label: Text('Program Term')),
              DataColumn(label: Text('Division')),
            ],
            rows: students
                .map(
                  (student) => DataRow(cells: [
                DataCell(Text(student.name)),
                DataCell(Text(student.program)),
                DataCell(Text(student.programTerm)),
                DataCell(Text(student.division)),
              ]),
            )
                .toList(),
          ),
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StudentListScreen(),
  ));
}

