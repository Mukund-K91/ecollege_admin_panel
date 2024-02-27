import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String grade;

  Student({
    required this.id,
    required this.name,
    required this.grade,
  });
}

class AdminDeleteStudentPage extends StatefulWidget {
  @override
  _AdminDeleteStudentPageState createState() => _AdminDeleteStudentPageState();
}

class _AdminDeleteStudentPageState extends State<AdminDeleteStudentPage> {
  final CollectionReference studentsCollection =
  FirebaseFirestore.instance.collection('students');

  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Delete Student'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: studentsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          List<Student> students = snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Student(
              id: doc.id,
              name: data['name'],
              grade: data['grade'],
            );
          }).toList();

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              Student student = students[index];
              return ListTile(
                title: Text(student.name),
                subtitle: Text(student.grade),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _confirmDelete(context, student),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please enter your password to confirm deletion:'),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_passwordController.text == 'your_admin_password') {
                  _deleteStudent(student);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid password')),
                  );
                }
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _deleteStudent(Student student) {
    studentsCollection.doc(student.id).delete();
  }
}

void main() {
  runApp(MaterialApp(
    home: AdminDeleteStudentPage(),
  ));
}
