import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String firstname;
  final String middlename;
  final String lastname;
  final String gender;
  final String userId;
  final String activationDate;
  final String profile;
  final String email;
  final String mobile;
  final String DOB;
  final String program;
  final String programTerm;
  final String division;
  final String password;

  Student({required this.firstname,
    required this.middlename,
    required this.lastname,
    required this.gender,
    required this.userId,
    required this.activationDate,
    required this.profile,
    required this.email,
    required this.mobile,
    required this.DOB,
    required this.program,
    required this.programTerm,
    required this.division,
    required this.password});

  // Convert Student object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      "First Name": firstname,
      "Middle Name": middlename,
      "Last Name": lastname,
      "Gender": gender,
      "User Id": userId,
      "Activation Date": activationDate,
      "Profile Img": profile,
      "Email": email,
      "Mobile": mobile,
      "DOB": DOB,
      'program': program,
      'programTerm': programTerm,
      'division': division,
      'Password': password,
    };
  }
}

class YourPage extends StatefulWidget {
  @override
  _YourPageState createState() => _YourPageState();
}

class _YourPageState extends State<YourPage> {
  final _firestore = FirebaseFirestore.instance;

  // Function to display the dialog box with pre-filled student data
  void _showEditDialog(BuildContext context, Student student) {
    TextEditingController firstNameController =
    TextEditingController(text: student.firstname);
    TextEditingController lastNameController =
    TextEditingController(text: student.lastname);
    // Add controllers for other fields

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Student Data'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                // Add text fields for other fields
              ],
            ),
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
                // Update the student's data in Firestore
                _updateStudentData(
                  student.userId,
                  firstNameController.text,
                  lastNameController.text,
                  // Pass other updated values here
                );
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // Function to update student data in Firestore
  void _updateStudentData(
      String userId,
      String newFirstName,
      String newLastName,
      // Add other updated values here
      ) {
    try {
      _firestore
          .collection('students')
          .doc(userId)
          .update({
        'firstname': newFirstName,
        'lastname': newLastName,
        // Update other fields similarly
      })
          .then((value) => print('Student data updated successfully'))
          .catchError((error) => print('Failed to update student data: $error'));
    } catch (e) {
      print('Error updating student data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Page'),
      ),
      body: _buildStudentList(),
    );
  }

  Widget _buildStudentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('students').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        List<Student> students = [];
        snapshot.data!.docs.forEach((doc) {
          Student student = Student(
            userId: doc.id,
              firstname: doc['First Name'],
              middlename: doc['Middle Name'],
              lastname: doc['Last Name'],
              gender: doc['Gender'],
              activationDate: doc['Activation Date'],
              profile: doc['Profile Img'],
              email: doc['Email'],
              mobile: doc['Mobile'],
              DOB: doc['DOB'],
              program: doc['program'],
              programTerm: doc['programTerm'],
              division: doc['division'],
              password: doc['Password']
          );
          students.add(student);
        });

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            Student student = students[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(student.profile),
              ),
              title: Text('${student.firstname} ${student.lastname}'),
              subtitle: Text(student.program),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showEditDialog(context, student);
                },
              ),
            );
          },
        );
      },
    );
  }
}
