import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../firebase_options.dart';
import '../storage_service.dart';

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

  Student(
      {required this.firstname,
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

class AttendanceRecord {
  final String subject;
  int presentCount;
  int absentCount;

  AttendanceRecord({
    required this.subject,
    this.presentCount = 0,
    this.absentCount = 0,
  });
}


class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch students from Firestore based on program, program term, and division
  Stream<List<Student>> getStudents(
      String program, String programTerm, String division) {
    return _firestore
        .collection('students')
        .doc(program)
        .collection(programTerm)
        .doc(division)
        .collection('student')
        .orderBy('User Id')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Student(
      firstname: doc['First Name'],
      middlename: doc['Middle Name'],
      lastname: doc['Last Name'],
      gender: doc['Gender'],
      userId: doc['User Id'],
      activationDate: doc['Activation Date'],
      profile: doc['Profile Img'],
      email: doc['Email'],
      mobile: doc['Mobile'],
      DOB: doc['DOB'],
      program: doc['program'],
      programTerm: doc['programTerm'],
      division: doc['division'],
      password: doc['Password'],
    ))
        .toList());
  }

  Stream<List<Student>> searchStudents(
      String program, String programTerm, String division, String searchTerm) {
    return _firestore
        .collection('students')
        .doc(program)
        .collection(programTerm)
        .doc(division)
        .collection('student')
        .where('First Name', isGreaterThanOrEqualTo: searchTerm)
        .where('First Name', isLessThanOrEqualTo: searchTerm + '\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Student(
      firstname: doc['First Name'],
      middlename: doc['Middle Name'],
      lastname: doc['Last Name'],
      gender: doc['Gender'],
      userId: doc['User Id'],
      activationDate: doc['Activation Date'],
      profile: doc['Profile Img'],
      email: doc['Email'],
      mobile: doc['Mobile'],
      DOB: doc['DOB'],
      program: doc['program'],
      programTerm: doc['programTerm'],
      division: doc['division'],
      password: doc['Password'],
    ))
        .toList());
  }
}

final _programs = ["--Please Select--", "BCA", "B-Com", "BBA"];
final _programTerm = [
  "--Please Select--",
  "Sem - 1",
  "Sem - 2",
  "Sem - 3",
  "Sem - 4",
  "Sem - 5",
  "Sem - 6"
];
final _Bcadivision = ["--Please Select--", "A", "B", "C", "D", "E", "F"];
final _Bcomdivision = ["--Please Select--", "A", "B", "C", "D", "E", "F", "G"];
final _Bbadivision = ["--Please Select--", "A", "B", "C", "D"];

late TextEditingController _totalStudentsController = TextEditingController();
final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
StorageService service = StorageService();

StorageService storageService = StorageService();
late DocumentReference _UserIdDoc;
int _totalStudent = 0;
late String imjUrl;
/*===============================================*/
/*===============================================*/
/*===============================================*/

List<Map<String, dynamic>> studentList = [];
List<int> clickCounts = [];

// class Attendance extends StatefulWidget {
//   final program;
//
//   const Attendance({super.key, this.program});
//
//   void main() async {
//     WidgetsFlutterBinding.ensureInitialized();
//     Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     //  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: SystemUiOverlay.values);
//   }
//
//   @override
//   _AttendanceState createState() => _AttendanceState();
// }
//
// class _AttendanceState extends State<Attendance> {
//   bool passwordObscured = true;
//   List<int> clickCounts = [];
//
//   void _changeColorAndText(int index) {
//     setState(() {
//       clickCounts[index] = (clickCounts[index] + 1) % 3;
//     });
//   }
//
//   Color _getButtonColor(int index) {
//     switch (clickCounts[index]) {
//       case 1:
//         return Colors.green;
//       case 2:
//         return Colors.red;
//       default:
//         return Colors.white;
//     }
//   }
//
//   String _getButtonText(int index) {
//     switch (clickCounts[index]) {
//       case 1:
//         return 'Present';
//       case 2:
//         return 'Absent';
//       default:
//         return 'Take';
//     }
//   }
//
//   final FirestoreService _firestoreService = FirestoreService();
//   late TextEditingController _searchController;
//   String? _selectedProgramTerm = "Sem - 6";
//   String? _selectedDivision = "C";
//   late String _searchTerm;
//   ScrollController _dataController1 = ScrollController();
//   ScrollController _dataController2 = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     _searchTerm = '';
//     _searchController = TextEditingController();
//     _UserIdDoc =
//         FirebaseFirestore.instance.collection('metadata').doc('userId');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student List'),
//       ),
//       body: Column(
//         children: [
//           _buildFilters(),
//           Expanded(
//             child: _buildStudentList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilters() {
//     final String _selectedProgram = widget.program;
//
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               decoration: const InputDecoration(
//                 labelText: 'Search',
//                 hintText: 'Search by name',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   _searchTerm = value;
//                 });
//               },
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text('Program : ${widget.program}'),
//           const SizedBox(width: 8),
//           DropdownButton<String>(
//             value: _selectedProgramTerm,
//             onChanged: (String? value) {
//               setState(() {
//                 _selectedProgramTerm = value!;
//               });
//             },
//             items: _selectedProgram == ''
//                 ? []
//                 : _programTerm.map<DropdownMenuItem<String>>(
//                     (String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     },
//                   ).toList(),
//             hint: const Text('Program Term'),
//           ),
//           const SizedBox(width: 8),
//           DropdownButton<String>(
//             value: _selectedDivision,
//             onChanged: (String? value) {
//               setState(() {
//                 _selectedDivision = value!;
//               });
//             },
//             items: _selectedProgramTerm == '--Please Select--'
//                 ? []
//                 : _selectedProgram == "BCA"
//                     ? _Bcadivision.map((e) => DropdownMenuItem(
//                           value: e,
//                           child: Text(e),
//                         )).toList()
//                     : _selectedProgram == "B-Com"
//                         ? _Bcomdivision.map((e) => DropdownMenuItem(
//                               value: e,
//                               child: Text(e),
//                             )).toList()
//                         : _Bbadivision.map((e) => DropdownMenuItem(
//                               value: e,
//                               child: Text(e),
//                             )).toList(),
//             hint: const Text('Class'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStudentList() {
//     final String _selectedProgram = widget.program;
//     int rollnumber = 0;
//     return StreamBuilder<List<Student>>(
//       stream: _searchTerm.isEmpty
//           ? _firestoreService.getStudents(
//               _selectedProgram!, _selectedProgramTerm!, _selectedDivision!)
//           : _firestoreService.searchStudents(_selectedProgram!,
//               _selectedProgramTerm!, _selectedDivision!, _searchTerm),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Center(
//             child: Text('Error: ${snapshot.error}'),
//           );
//         }
//
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }
//
//         final students = snapshot.data;
//
//         if (students == null || students.isEmpty) {
//           return const Center(
//             child: Text('No students found'),
//           );
//         }
//         if (clickCounts.isEmpty) {
//           clickCounts = List.generate(students.length, (_) => 0);
//         }
//         return ListView.builder(
//           itemCount: students.length,
//           itemBuilder: (context, index) {
//             final student = students[index];
//             rollnumber++;
//             return Card(
//               child: ListTile(
//                 leading: CircleAvatar(
//                   child: Text(
//                     '${rollnumber}',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//                   ),
//                 ),
//                 title: Text(
//                   student.firstname + " " + student.lastname,
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: Text(student.userId),
//                 trailing: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                       maximumSize: Size(100, 40),
//                       backgroundColor: _getButtonColor(index),
//                       minimumSize: Size(100, 40)),
//                   onPressed: () {
//                     _changeColorAndText(index);
//                   },
//                   child: Text(
//                     _getButtonText(index),
//                     style: TextStyle(
//                         color: Colors.black, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

class Attendance extends StatefulWidget {
  final program;

  const Attendance({Key? key, this.program});

  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  late String _selectedProgramTerm;
  late String _selectedDivision;
  late String _searchTerm;
  late FirestoreService _firestoreService;
  late TextEditingController _searchController;
  late DocumentReference _UserIdDoc;
  List<AttendanceRecord> attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    _selectedProgramTerm = 'Sem - 6';
    _selectedDivision = 'C';
    _searchTerm = '';
    _firestoreService = FirestoreService();
    _searchController = TextEditingController();
    _UserIdDoc = FirebaseFirestore.instance.collection('metadata').doc('userId');
  }
  void _toggleAttendance(int index, bool isPresent) {
    setState(() {
      if (isPresent) {
        attendanceRecords[index].presentCount++;
      } else {
        attendanceRecords[index].absentCount++;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
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
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
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
          const SizedBox(width: 8),
          Text('Program : ${widget.program}'),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedProgramTerm,
            onChanged: (String? value) {
              setState(() {
                _selectedProgramTerm = value!;
              });
            },
            items: _programTerm.map<DropdownMenuItem<String>>(
                  (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              },
            ).toList(),
            hint: const Text('Program Term'),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedDivision,
            onChanged: (String? value) {
              setState(() {
                _selectedDivision = value!;
              });
            },
            items: _Bcadivision.map<DropdownMenuItem<String>>(
                  (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              },
            ).toList(),
            hint: const Text('Class'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    return StreamBuilder<List<Student>>(
      stream: _searchTerm.isEmpty
          ? _firestoreService.getStudents(
          widget.program!, _selectedProgramTerm, _selectedDivision)
          : _firestoreService.searchStudents(
          widget.program!, _selectedProgramTerm, _selectedDivision, _searchTerm),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final students = snapshot.data;

        if (students == null || students.isEmpty) {
          return const Center(
            child: Text('No students found'),
          );
        }
        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return StudentListItem(
              student: student,
              onPressed: (isPresent) {
                // Update the database or perform any other action based on the attendance status
              },
            );
          },
        );
      },
    );
  }
}

class StudentListItem extends StatefulWidget {
  final Student student;
  final Function(bool) onPressed;

  const StudentListItem({
    Key? key,
    required this.student,
    required this.onPressed,
  }) : super(key: key);

  @override
  _StudentListItemState createState() => _StudentListItemState();
}

class _StudentListItemState extends State<StudentListItem> {
  bool isPresent = true; // Assuming present by default

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          widget.student.firstname + " " + widget.student.lastname,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(widget.student.userId),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            maximumSize: Size(100, 40),
            backgroundColor: isPresent ? Colors.green : Colors.red,
            minimumSize: Size(100, 40),
          ),
          onPressed: () {
            setState(() {
              isPresent = !isPresent;
              widget.onPressed(isPresent);
            });
          },
          child: Text(
            isPresent ? 'Present' : 'Absent',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
