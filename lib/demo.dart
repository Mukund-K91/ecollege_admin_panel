import 'package:flutter/material.dart';

void main() {
  runApp(StudentList());
}

class Student {
  final String name;
  final String className;

  Student({required this.name, required this.className});
}

class StudentList extends StatefulWidget {
  @override
  _StudentListState createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  late List<Student> _students;
  late List<Student> _filteredStudents;
  late String _selectedClass;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _students = [
      Student(name: 'John Doe', className: 'Class A'),
      Student(name: 'Jane Smith', className: 'Class B'),
      Student(name: 'Alice Johnson', className: 'Class A'),
      Student(name: 'Bob Williams', className: 'Class B'),
    ];
    _filteredStudents = _students;
    _selectedClass = 'All';
    _searchController = TextEditingController();
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
                    items: ['All', 'Class A', 'Class B']
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
