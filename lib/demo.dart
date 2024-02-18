import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(StudentList());
}

class StudentList extends StatefulWidget {
  @override
  _StudentListState createState() => _StudentListState();
}

class Student {
  final String name;
  final String className;

  Student({required this.name, required this.className});
}

class _StudentListState extends State<StudentList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late List<Student> _students;
  late List<Student> _filteredStudents;
  late String _selectedClass;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _students = [];
    _filteredStudents = [];
    _selectedClass = 'All';
    _searchController = TextEditingController();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await _firestore.collection('students').get();
    final List<Student> students = querySnapshot.docs.map((doc) {
      return Student(
        name: doc['First Name'],
        className: doc['Division'],
      );
    }).toList();
    setState(() {
      _students = students;
      _filteredStudents = _students;
    });
  }

  void _filterStudents() {
    setState(() {
      _filteredStudents = _students.where((student) {
        if (_selectedClass == 'All' || student.className == _selectedClass) {
          final query = _searchController.text.toLowerCase();
          return student.name.toLowerCase().contains(query);
        }
        return false;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student List',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Student List'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedClass,
                    onChanged: (value) {
                      setState(() {
                        _selectedClass = value!;
                        _filterStudents();
                      });
                    },
                    items: ['All', 'A', 'B']
                        .map((className) => DropdownMenuItem<String>(
                      value: className,
                      child: Text(className),
                    ))
                        .toList(),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => _filterStudents(),
                      decoration: InputDecoration(
                        hintText: 'Search by name',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Class')),
                    ],
                    rows: _filteredStudents.map((student) {
                      return DataRow(
                        cells: [
                          DataCell(Text(student.name)),
                          DataCell(Text(student.className)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
