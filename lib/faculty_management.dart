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

class Faculty {
  final String firstname;
  final String lastname;
  final String gender;
  final String FacultyId;
  final String profile;
  final String email;
  final String mobile;
  final String qualification;
  final String Designation;
  final String program;

  Faculty(
      {required this.firstname,
      required this.lastname,
      required this.gender,
      required this.FacultyId,
      required this.profile,
      required this.email,
      required this.mobile,
      required this.program,
      required this.qualification,
      required this.Designation});

  // Convert Student object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      "First Name": firstname,
      "Last Name": lastname,
      "Gender": gender,
      "Id": FacultyId,
      "Profile Img": profile,
      "Email": email,
      "Mobile": mobile,
      'program': program,
      "Qualification": qualification,
      "Designation":Designation
    };
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add student to Firestore
  Future<void> addFaculty(Faculty faculty) async {
    try {
      await _firestore
          .collection('faculty')
          .doc(faculty.program)
          .collection('faculty')
          .doc(faculty.FacultyId)
          .set(faculty.toMap());
      print("Done");
    } catch (e) {
      print('Error adding student: $e');
    }
  }

  // Fetch students from Firestore based on program, program term, and division
  Stream<List<Faculty>> getFaculty(String program) {
    return _firestore
        .collection('faculty')
        .doc(program)
        .collection('faculty')
        .orderBy('Id')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Faculty(
                firstname: doc['First Name'],
                lastname: doc['Last Name'],
                gender: doc['Gender'],
                FacultyId: doc['Id'],
                profile: doc['Profile Img'],
                email: doc['Email'],
                mobile: doc['Mobile'],
                program: doc['program'],
                qualification: doc['Qualification'],
                Designation: doc['Designation']))
            .toList());
  }

  Stream<List<Faculty>> searchFaculty(String program, String searchTerm) {
    return _firestore
        .collection('faculty')
        .doc(program)
        .collection('faculty')
        .orderBy('Id')
        .where('Id', isGreaterThanOrEqualTo: searchTerm)
        .where('Id', isLessThanOrEqualTo: searchTerm + '\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Faculty(
                firstname: doc['First Name'],
                lastname: doc['Last Name'],
                gender: doc['Gender'],
                FacultyId: doc['Id'],
                profile: doc['Profile Img'],
                email: doc['Email'],
                mobile: doc['Mobile'],
                program: doc['program'],
                qualification: doc['Qualification'],
                Designation: doc['Designation']))
            .toList());
  }
}

class AddFaculty extends StatefulWidget {
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    //  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: SystemUiOverlay.values);
  }

  @override
  _AddFacultyState createState() => _AddFacultyState();
}

class _AddFacultyState extends State<AddFaculty> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _searchController = TextEditingController();
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  StorageService service = StorageService();

  StorageService storageService = StorageService();
  late CollectionReference _studentsCollection;
  late DocumentReference _UserIdDoc;
  int _totalFaculty = 0;
  late String imjUrl;

  String? _selectedGender;
  DateTime? _selectedDate;
  final _programs = ["--Please Select--", "BCA", "B-Com", "BBA"];
  late String _selProgram = '--Please Select--';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _facultyId = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _Qualification = TextEditingController();
  final TextEditingController _Designation = TextEditingController();
  late TextEditingController _fileNameController = TextEditingController();

  late TextEditingController _totalFacultyController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  void initState() {
    super.initState();
    _UserIdDoc =
        FirebaseFirestore.instance.collection('metadata').doc('FacultyId');
    _getUserId();
    _totalFacultyController = TextEditingController();
  }

  Future<void> _getUserId() async {
    final userIdDocSnapshot = await _UserIdDoc.get();
    setState(() {
      _totalFaculty =
          userIdDocSnapshot.exists && userIdDocSnapshot.data() != null
              ? (userIdDocSnapshot.data()
                      as Map<String, dynamic>)['Total Faculty'] ??
                  0
              : 0;
      _totalFacultyController.text = _totalFaculty.toString();
    });
  }

  Future<void> _incrementRollNumber() async {
    _totalFaculty++;
    await _UserIdDoc.set({'Total Faculty': _totalFaculty});
  }

  @override
  void dispose() {
    _totalFacultyController.dispose();
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
                  "Manage Faculty",
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
                            controller: _facultyId,
                            maxLength: 10,
                            keyboardType: TextInputType.phone,
                            readOnly: false,
                            title: 'Id',
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
                            controller: _firstNameController,
                            keyboardType: TextInputType.name,
                            readOnly: false,
                            title: 'First Name',
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
                            title: 'Last Name',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
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
                                            color: Colors.grey, fontSize: 15)),
                                  ],
                                ),
                              ],
                            )
                          ],
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
                      ],
                    ),
                    SizedBox(
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
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ReusableTextField(
                            controller: _Designation,
                            keyboardType: TextInputType.name,
                            readOnly: false,
                            validator: (str) {
                              if (str!.isEmpty) {
                                return "Designation  is required";
                              }
                              return null;
                            },
                            title: 'Designation ',
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: ReusableTextField(
                            controller: _Qualification,
                            keyboardType: TextInputType.name,
                            readOnly: false,
                            validator: (str) {
                              if (str!.isEmpty) {
                                return "Qualification  is required";
                              }
                              return null;
                            },
                            title: 'Qualification ',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
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
                            Faculty newStudent = Faculty(
                              firstname: _firstNameController.text,
                              lastname: _lastNameController.text,
                              gender: _selectedGender.toString(),
                              profile: imjUrl.toString(),
                              FacultyId: _facultyId.text,
                              email: _emailController.text,
                              mobile: _phoneController.text,
                              program: _selProgram.toString(),
                              qualification: _Qualification.text,
                              Designation: _Designation.text,
                            );
                            _firestoreService.addFaculty(newStudent);

                            _firstNameController.text = "";
                            _fileNameController.text = "";
                            _middleNameController.text = "";
                            _lastNameController.text = "";
                            _selectedGender = "";
                            _emailController.text = "";
                            _phoneController.text = "";
                            _selProgram = _programs[0];
                            _Qualification.text = "";
                            _Designation.text = "";

                            await _incrementRollNumber();
                            // Update TextField value after increment
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

class FacultyList extends StatefulWidget {
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    //  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: SystemUiOverlay.values);
  }

  @override
  _FacultyListState createState() => _FacultyListState();
}

class _FacultyListState extends State<FacultyList> {
  final FirestoreService _firestoreService = FirestoreService();
  late TextEditingController _searchController;
  late String _selectedProgram = '--Program--';
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
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    return StreamBuilder<List<Faculty>>(
      stream: _searchTerm.isEmpty
          ? _firestoreService.getFaculty(_selectedProgram)
          : _firestoreService.searchFaculty(_selectedProgram, _searchTerm),
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
            child: Text('No Data found'),
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
                  DataColumn(label: Text('Id')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Profile')),
                  DataColumn(label: Text('Program')),
                  DataColumn(label: Text('Mobile')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Qualification')),
                  DataColumn(label: Text('Designation')),
                  DataColumn(label: Text('Action')),
                ],
                rows: students
                    .map(
                      (student) => DataRow(cells: [
                        DataCell(Text(student.FacultyId)),
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
                        DataCell(Text(student.mobile)),
                        DataCell(Text(student.email)),
                        DataCell(Text(student.qualification)),
                        DataCell(Text(student.Designation)),
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