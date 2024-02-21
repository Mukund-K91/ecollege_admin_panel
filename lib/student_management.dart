import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecollege_admin_panel/reusable_widget/reusable_textfield.dart';
import 'package:ecollege_admin_panel/storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'firebase_options.dart';

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
      required this.division});

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
          .collection('student')
          .doc(student.userId)
          .set(student.toMap());
      print("Done");
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
        .collection('student')
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
        .where('Mobile', isGreaterThanOrEqualTo: searchTerm)
        .where('Mobile', isLessThanOrEqualTo: searchTerm + '\uf8ff')
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
                ))
            .toList());
  }
}

class AddStudents extends StatefulWidget {
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    //  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: SystemUiOverlay.values);
  }

  @override
  _AddStudentsState createState() => _AddStudentsState();
}

class _AddStudentsState extends State<AddStudents> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _searchController = TextEditingController();
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  StorageService service = StorageService();

  StorageService storageService = StorageService();
  late CollectionReference _studentsCollection;
  late DocumentReference _UserIdDoc;
  int _lastUserId = 202400101;
  int _totalStudent = 0;
  late String imjUrl;

  String? _selectedGender;
  DateTime? _selectedDate;
  final _programs = ["--Please Select--", "BCA", "B-Com", "BBA"];
  String? _selProgram = "--Please Select--";
  final _programTerm = [
    "--Please Select--",
    "Sem-1",
    "Sem-2",
    "Sem-3",
    "Sem-4",
    "Sem-5",
    "Sem-6"
  ];
  String? _selProgramTerm = "--Please Select--";
  final _Bcadivision = ["--Please Select--", "A", "B", "C", "D", "E", "F"];
  final _Bcomdivision = [
    "--Please Select--",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G"
  ];
  final _Bbadivision = ["--Please Select--", "A", "B", "C", "D"];
  String? _seldiv = "--Please Select--";
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late TextEditingController _UserIdController;
  final TextEditingController _dobController = TextEditingController();
  late TextEditingController _fileNameController = TextEditingController();
  late TextEditingController _totalStudentsController = TextEditingController();
  DateTime _activationDate = DateTime.now();
  TextEditingController _activeDate = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  void initState() {
    super.initState();
    _UserIdDoc =
        FirebaseFirestore.instance.collection('metadata').doc('userId');
    _getUserId();
    _UserIdController = TextEditingController();
    _totalStudentsController = TextEditingController();
  }

  Future<void> _getUserId() async {
    final userIdDocSnapshot = await _UserIdDoc.get();
    setState(() {
      _lastUserId = userIdDocSnapshot.exists && userIdDocSnapshot.data() != null
          ? (userIdDocSnapshot.data() as Map<String, dynamic>)['lastUserId'] ??
              202400101
          : 202400101;
      _UserIdController.text = _lastUserId.toString();
      _totalStudent =
          userIdDocSnapshot.exists && userIdDocSnapshot.data() != null
              ? (userIdDocSnapshot.data()
                      as Map<String, dynamic>)['Total Students'] ??
                  0
              : 0;
      _totalStudentsController.text = _totalStudent.toString();
    });
  }

  Future<void> _incrementRollNumber() async {
    _lastUserId++;
    _totalStudent++;
    await _UserIdDoc.set(
        {'lastUserId': _lastUserId, 'Total Students': _totalStudent});
  }

  @override
  void dispose() {
    _UserIdController.dispose();
    _totalStudentsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd-MM-yyyy').format(_selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Manage Students",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ReusableTextField(
                            controller: _firstNameController,
                            keyboardType: TextInputType.name,
                            readOnly: false,
                            validator: (str) {
                              if (str!.isEmpty) {
                                return "First Name is required";
                              }
                              return null;
                            },
                            title: 'First Name',
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: ReusableTextField(
                            controller: _middleNameController,
                            keyboardType: TextInputType.name,
                            readOnly: false,
                            validator: (str) {
                              if (str!.isEmpty) {
                                return "Last Name is required";
                              }
                              return null;
                            },
                            title: 'Middle Name',
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: ReusableTextField(
                            controller: _lastNameController,
                            keyboardType: TextInputType.name,
                            readOnly: false,
                            validator: (str) {
                              if (str!.isEmpty) {
                                return "Last Name is required";
                              }
                              return null;
                            },
                            title: 'Last Name',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Gender:",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Male',
                                        groupValue: _selectedGender,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedGender = value;
                                          });
                                        },
                                      ),
                                      const Text(
                                        'Male',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Female',
                                        groupValue: _selectedGender,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedGender = value;
                                          });
                                        },
                                      ),
                                      const Text('Female',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 15)),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        )),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                  child: Column(
                                children: [
                                  ReusableTextField(
                                    readOnly: true,
                                    controller: _fileNameController,
                                    title: 'Image',
                                    sufIcon: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              minimumSize: Size(100, 50),
                                              backgroundColor:
                                                  const Color(0xff002233),
                                              shape:
                                                  ContinuousRectangleBorder()),
                                          onPressed: () async {
                                            var result = await FilePicker
                                                .platform
                                                .pickFiles(
                                                    allowMultiple: true,
                                                    type: FileType.image);
                                            if (result == null) {
                                              print("Error: No file selected");
                                            } else {
                                              var path =
                                                  result.files.single.bytes;
                                              final fileName =
                                                  result.files.single.name;

                                              setState(() {
                                                _fileNameController.text =
                                                    fileName;
                                                result = null;
                                              });

                                              try {
                                                await firebaseStorage
                                                    .ref('Profiles/$fileName')
                                                    .putData(path!)
                                                    .then((p0) async {
                                                  log("Uploaded");
                                                });
                                              } catch (e) {
                                                log("Error: $e");
                                              }
                                              var imgurl = await firebaseStorage
                                                  .ref('Profiles/$fileName')
                                                  .getDownloadURL();
                                              print(imgurl);
                                              imjUrl = imgurl.toString();
                                              print("imj" + imjUrl);
                                            }

                                            // html.FileUploadInputElement
                                            //     uploadInput =
                                            //     html.FileUploadInputElement()
                                            //       ..accept = 'image/*';
                                            // uploadInput.click();
                                            // uploadInput.onChange
                                            //     .listen((event) {
                                            //   final files = uploadInput.files;
                                            //   if (files != null &&
                                            //       files.length == 1) {
                                            //     final file = files[0];
                                            //     _handleFileUpload(file);
                                            //   }
                                            // });
                                          },
                                          child: const Text(
                                            "Upload",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                          )),
                                    ),
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: ReusableTextField(
                            controller: _UserIdController,
                            maxLength: 10,
                            keyboardType: TextInputType.phone,
                            readOnly: true,
                            title: 'User Id',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ReusableTextField(
                            controller: _emailController,
                            keyboardType: TextInputType.name,
                            readOnly: false,
                            validator: (str) {
                              if (str!.isEmpty) {
                                return "Email is required";
                              }
                              return null;
                            },
                            title: 'Email',
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: ReusableTextField(
                            controller: _phoneController,
                            maxLength: 10,
                            keyboardType: TextInputType.phone,
                            readOnly: false,
                            validator: (str) {
                              if (str!.isEmpty) {
                                return "Mobile is required";
                              }
                              return null;
                            },
                            title: 'Mobile',
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                            flex: 1,
                            child: ReusableTextField(
                              controller: _dobController,
                              OnTap: () => _selectDate(context),
                              title: 'DOB',
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(
                              "Program",
                              style: TextStyle(fontSize: 15),
                            ),
                            subtitle: DropdownButtonFormField(
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.all(Radius.zero))),
                                value: _selProgram,
                                items: _programs
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selProgram = val as String;
                                  });
                                }),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              "Program Term",
                              style: TextStyle(fontSize: 15),
                            ),
                            subtitle: DropdownButtonFormField(
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.all(Radius.zero))),
                                value: _selProgramTerm,
                                items: _programTerm
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selProgramTerm = val as String;
                                  });
                                }),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              "Division",
                              style: TextStyle(fontSize: 15),
                            ),
                            subtitle: DropdownButtonFormField(
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.all(Radius.zero))),
                                value: _seldiv,
                                items: _selProgram == "BCA"
                                    ? _Bcadivision.map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        )).toList()
                                    : _selProgram == "B-Com"
                                        ? _Bcomdivision.map(
                                            (e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(e),
                                                )).toList()
                                        : _Bbadivision.map(
                                            (e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(e),
                                                )).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _seldiv = val as String;
                                  });
                                }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            maximumSize: Size(180, 65),
                            minimumSize: Size(150, 60),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.zero)),
                            backgroundColor: const Color(0xff002233),
                          ),
                          onPressed: () async {
                            final _activedate = DateFormat('dd-MMMM-yyyy')
                                .format(_activationDate);

                            Student newStudent = Student(
                              firstname: _firstNameController.text,
                              middlename: _middleNameController.text,
                              lastname: _lastNameController.text,
                              gender: _selectedGender.toString(),
                              profile: imjUrl.toString(),
                              userId: _lastUserId.toString(),
                              email: _emailController.text,
                              mobile: _phoneController.text,
                              program: _selProgram.toString(),
                              programTerm: _selProgramTerm.toString(),
                              division: _seldiv.toString(),
                              DOB: _dobController.text,
                              activationDate: _activedate,
                            );
                            _firestoreService.addStudent(newStudent);

                            _firstNameController.text = "";
                            _fileNameController.text = "";
                            _middleNameController.text = "";
                            _lastNameController.text = "";
                            _selectedGender = "";
                            _emailController.text = "";
                            _phoneController.text = "";
                            _dobController.text = "";
                            _selProgram = "";
                            _selProgramTerm = "";
                            _seldiv = "";

                            await _incrementRollNumber();
                            // Update TextField value after increment
                            _UserIdController.text = _lastUserId.toString();
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*===============================================*/
/*===============================================*/
/*===============================================*/

class StudentList extends StatefulWidget {
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    //  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: SystemUiOverlay.values);
  }

  @override
  _StudentListState createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  final FirestoreService _firestoreService = FirestoreService();
  late TextEditingController _searchController;
  late String _selectedProgram = '--Program--';
  late String _selectedProgramTerm = '--Program Term';
  late String _selectedDivision = '--Division--';
  late String _searchTerm;
  ScrollController _dataController1 = ScrollController();
  ScrollController _dataController2 = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchTerm = '';
    _searchController = TextEditingController();
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
          SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedProgram,
            onChanged: (String? value) {
              setState(() {
                _selectedProgram = value!;
                _selectedProgramTerm = '--Program Term--';
              });
            },
            items: ['--Program--', 'BCA', 'BBA', 'B-Com']
                .map<DropdownMenuItem<String>>(
              (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              },
            ).toList(),
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
            items: _selectedProgram.isEmpty || _selectedProgram == '--Program--'
                ? []
                : [
                    '--Program Term--',
                    'Sem-1',
                    'Sem-2',
                    'Sem-3',
                    'Sem-4',
                    'Sem-5',
                    'Sem-6'
                  ].map<DropdownMenuItem<String>>(
                    (String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    },
                  ).toList(),
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
            items: _selectedProgramTerm.isEmpty ||
                    _selectedProgramTerm == '--Program Term'
                ? []
                : ['--Division--', 'A', 'B', 'C', 'D']
                    .map<DropdownMenuItem<String>>(
                    (String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    },
                  ).toList(),
            hint: Text('Class'),
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
          : _firestoreService.searchStudents(_selectedProgram,
              _selectedProgramTerm, _selectedDivision, _searchTerm),
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

        return RawScrollbar(
          padding: EdgeInsets.all(20),
          thumbVisibility: true,
          trackVisibility: true,
          thumbColor: Color(0xff002233),
          controller: _dataController2,
          child: SingleChildScrollView(
            controller: _dataController2,
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              controller: _dataController1,
              child: DataTable(
                border: TableBorder.all(),
                columns: const [
                  DataColumn(label: Text('User Id')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Profile')),
                  DataColumn(label: Text('Program')),
                  DataColumn(label: Text('Program Term')),
                  DataColumn(label: Text('Division')),
                  DataColumn(label: Text('Activation Date')),
                  DataColumn(label: Text('DOB')),
                  DataColumn(label: Text('Mobile')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Action')),
                ],
                rows: students
                    .map(
                      (student) => DataRow(cells: [
                        DataCell(Text(student.userId)),
                        DataCell(
                            Text(student.firstname + " " + student.lastname)),
                        DataCell(CircleAvatar(
                          radius: 27,
                          child: ClipOval(
                            child: Image.network(
                              student.profile,
                              fit: BoxFit.cover,
                              height: 70,
                              width: 70,
                            ),
                          ),
                        )),
                        DataCell(Text(student.program)),
                        DataCell(Text(student.programTerm)),
                        DataCell(Text(student.division)),
                        DataCell(Text(student.activationDate)),
                        DataCell(Text(student.DOB)),
                        DataCell(Text(student.mobile)),
                        DataCell(Text(student.email)),
                        DataCell(Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  _showUpdateDialog(context);
                                },
                                icon: Icon(
                                  FontAwesomeIcons.edit,
                                  color: Colors.green,
                                )),
                            IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  FontAwesomeIcons.trash,
                                  color: Colors.redAccent,
                                )),
                          ],
                        ))
                      ]),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

void _showUpdateDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Update Student Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _updateStudentDetails();
              Navigator.of(context).pop();
            },
            child: Text('Submit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}

void _updateStudentDetails() {}
