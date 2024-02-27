import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
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
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:universal_html/html.dart' as html;
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
                  password: doc['Password'],
                ))
            .toList());
  }
}

Future<void> DeleteStudent(
    String program, String programTerm, String division, String userId) {
  return FirebaseFirestore.instance
      .collection('students')
      .doc(program)
      .collection(programTerm)
      .doc(division)
      .collection('student')
      .doc(userId)
      .delete();
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

final TextEditingController _firstNameController = TextEditingController();
final TextEditingController _middleNameController = TextEditingController();
final TextEditingController _lastNameController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _mobileNoController = TextEditingController();
late TextEditingController _UserIdController;
final TextEditingController _dobController = TextEditingController();
late TextEditingController _fileNameController = TextEditingController();
late TextEditingController _totalStudentsController = TextEditingController();
TextEditingController _rollNumberController = TextEditingController();
DateTime _activationDate = DateTime.now();
TextEditingController _activeDate = TextEditingController();
final FirestoreService _firestoreService = FirestoreService();
final TextEditingController _searchController = TextEditingController();
final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
StorageService service = StorageService();

StorageService storageService = StorageService();
late CollectionReference _studentsCollection;
late DocumentReference _UserIdDoc;
int _lastUserId = 202400101;
int _totalStudent = 0;
late String imjUrl;

String? _selectedGender = 'Male';
DateTime? _selectedDate;

String? _selProgram = "--Please Select--";

String? _selProgramTerm = "--Please Select--";

String? _seldiv = "--Please Select--";
final _formKey = GlobalKey<FormState>();

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

  Future<Uint8List> generatePdf(
      String firstName,
      String lastName,
      String program,
      String programTerm,
      String division,
      String userId) async {
    final pdf = pdfLib.Document();

    pdf.addPage(
      pdfLib.Page(
        build: (context) {
          return pdfLib.Column(
            mainAxisAlignment: pdfLib.MainAxisAlignment.center,
            crossAxisAlignment: pdfLib.CrossAxisAlignment.center,
            children: [
              pdfLib.Text('Student Information',
                  style: pdfLib.TextStyle(fontSize: 20)),
              pdfLib.SizedBox(height: 20),
              pdfLib.Text('User Id: $userId'),
              pdfLib.Text('First Name: $firstName'),
              pdfLib.Text('Middle Name: $firstName'),
              pdfLib.Text('Last Name: $lastName'),
              pdfLib.Text('Program: $program'),
              pdfLib.Text('Program Term: $programTerm'),
              pdfLib.Text('Division: $division'),
            ],
          );
        },
      ),
    );

    // Save the PDF to bytes
    final Uint8List bytes = await pdf.save();

    // Convert bytes to Blob
    final blob = html.Blob([bytes], 'application/pdf');

    // Create download link
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "${userId}.pdf")
      ..click();

    // Clean up
    html.Url.revokeObjectUrl(url);

    return pdf.save();
  }

  // Variable to hold the current roll number
//  int currentRollNumber = 001;

// Function to initialize the roll number when program, programTerm, and division are selected
//   void initializeRollNumber(
//       String program, String programTerm, String division) async {
//     try {
//       final rollNumberDocPath = 'rollNo/$program/$programTerm/$division';
//       final rollNumberDocRef =
//           FirebaseFirestore.instance.doc(rollNumberDocPath);
//
//       // Fetch the last roll number
//       final rollNumberSnapshot = await rollNumberDocRef.get();
//       currentRollNumber = rollNumberSnapshot.exists
//           ? (rollNumberSnapshot.data()!['lastRollNumber'] as int)
//           : 001;
//       _rollNumberController.text = currentRollNumber.toString();
//     } catch (e) {
//       print('Error fetching roll number: $e');
//     }
//   }
//
// // Function to increment and store the roll number when the user clicks on submit
//   Future<void> incrementAndStoreRollNumber(
//       String program, String programTerm, String division) async {
//     try {
//       final rollNumberDocPath = 'rolls/$program/$programTerm/$division';
//       final rollNumberDocRef =
//           FirebaseFirestore.instance.doc(rollNumberDocPath);
//
//       // Increment the roll number
//       currentRollNumber++;
//
//       // Update the roll number in Firestore
//       await rollNumberDocRef.set({'lastRollNumber': currentRollNumber});
//     } catch (e) {
//       print('Error setting roll number: $e');
//     }
//   }

  Future<void> _incrementUserId() async {
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
                                  const SizedBox(
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
                                              minimumSize: const Size(100, 50),
                                              backgroundColor:
                                                  const Color(0xff002233),
                                              shape:
                                                  const ContinuousRectangleBorder()),
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
                            title: 'User Id (Login Id)',
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
                            title: 'Email',
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: ReusableTextField(
                            controller: _mobileNoController,
                            maxLength: 10,
                            keyboardType: TextInputType.phone,
                            readOnly: false,
                            title: 'Mobile',
                          ),
                        ),
                        const SizedBox(
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
                            title: const Text(
                              "Program",
                              style: TextStyle(fontSize: 15),
                            ),
                            subtitle: DropdownButtonFormField(
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      _selProgram == "--Please Select--") {
                                    return "Please Select Program";
                                  }
                                },
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
                            title: const Text(
                              "Program Term",
                              style: TextStyle(fontSize: 15),
                            ),
                            subtitle: DropdownButtonFormField(
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      _selProgramTerm == "--Please Select--") {
                                    return "Please Select Program Term";
                                  }
                                },
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
                            title: const Text(
                              "Division",
                              style: TextStyle(fontSize: 15),
                            ),
                            subtitle: DropdownButtonFormField(
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      _selProgram == '--Please Select--') {
                                    return "Please Select Division";
                                  }
                                },
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
                            maximumSize: const Size(180, 65),
                            minimumSize: const Size(150, 60),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.zero)),
                            backgroundColor: const Color(0xff002233),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final _activedate = DateFormat('dd-MMMM-yyyy')
                                  .format(_activationDate);

                              final _password = _mobileNoController.text;
                              Student newStudent = Student(
                                firstname: _firstNameController.text,
                                middlename: _middleNameController.text,
                                lastname: _lastNameController.text,
                                gender: _selectedGender.toString(),
                                profile: imjUrl.toString(),
                                userId: _lastUserId.toString(),
                                email: _emailController.text,
                                mobile: _mobileNoController.text,
                                program: _selProgram.toString(),
                                programTerm: _selProgramTerm.toString(),
                                division: _seldiv.toString(),
                                DOB: _dobController.text,
                                activationDate: _activedate,
                                password: _password,
                              );
                              Uint8List pdfBytes = await generatePdf(
                                  _firstNameController.text,
                                  _mobileNoController.text,
                                  _selProgram.toString(),
                                  _selProgramTerm.toString(),
                                  _seldiv.toString(),
                                  _lastUserId.toString());

                              _firestoreService.addStudent(newStudent);
                              _firstNameController.text = "";
                              _fileNameController.text = "";
                              _middleNameController.text = "";
                              _lastNameController.text = "";
                              _selectedGender = "";
                              _emailController.text = "";
                              _mobileNoController.text = "";
                              _dobController.text = "";
                              _selProgram = _programs[0];
                              _selProgramTerm = _programTerm[0];
                              _seldiv = "--Please Select--";

                              await _incrementUserId();
                              // Update TextField value after increment
                              _UserIdController.text = _lastUserId.toString();
                            }
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
  String? _selectedProgram = "--Please Select--";
  String? _selectedProgramTerm = "--Please Select--";
  String? _selectedDivision = "--Please Select--";
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
          DropdownButton<String>(
            value: _selectedProgram,
            onChanged: (String? value) {
              setState(() {
                _selectedProgram = value!;
                _selectedProgramTerm = '--Please Select--';
              });
            },
            items: _programs.map<DropdownMenuItem<String>>(
              (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              },
            ).toList(),
            hint: const Text('Program'),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedProgramTerm,
            onChanged: (String? value) {
              setState(() {
                _selectedProgramTerm = value!;
              });
            },
            items: _selectedProgram == '--Please Select--'
                ? []
                : _programTerm.map<DropdownMenuItem<String>>(
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
            items: _selectedProgramTerm == '--Please Select--'
                ? []
                : _selectedProgram == "BCA"
                    ? _Bcadivision.map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        )).toList()
                    : _selectedProgram == "B-Com"
                        ? _Bcomdivision.map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            )).toList()
                        : _Bbadivision.map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            )).toList(),
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
              _selectedProgram!, _selectedProgramTerm!, _selectedDivision!)
          : _firestoreService.searchStudents(_selectedProgram!,
              _selectedProgramTerm!, _selectedDivision!, _searchTerm),
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

        return RawScrollbar(
          padding: const EdgeInsets.all(20),
          thumbVisibility: true,
          trackVisibility: true,
          thumbColor: const Color(0xff002233),
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
                                  _updateStudentDetails(
                                      context,
                                      student,
                                      _selectedProgram!,
                                      _selectedProgramTerm!,
                                      _selectedDivision!,
                                      student.userId);
                                },
                                icon: const Icon(
                                  FontAwesomeIcons.edit,
                                  color: Colors.green,
                                )),
                            IconButton(
                                onPressed: () => _confirmDelete(
                                    context,
                                    _selectedProgram!,
                                    _selectedProgramTerm!,
                                    _selectedDivision!,
                                    student.userId),
                                icon: const Icon(
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

  final TextEditingController dobController = TextEditingController();
  DateTime? selectedDate;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dobController.text = DateFormat('dd-MM-yyyy').format(selectedDate!);
      });
    }
  }

  Future<void> _updateStudentDetails(
      BuildContext context,
      Student student,
      String program,
      String programTerm,
      String Division,
      String userId) async {
    DocumentSnapshot<Map<String, dynamic>> studentSnapshot =
        await FirebaseFirestore.instance
            .collection('students')
            .doc(student.program)
            .collection(student.programTerm)
            .doc(student.division)
            .collection('student')
            .doc(userId)
            .get();
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController middleNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController mobileNoController = TextEditingController();
    late TextEditingController fileNameController = TextEditingController();
    String? selProgram = "--Please Select--";
    String? selProgramTerm = "--Please Select--";
    String? seldiv = "--Please Select--";
    firstNameController.text = student.firstname;
    middleNameController.text = student.middlename;
    lastNameController.text = student.lastname;
    emailController.text = student.email;
    mobileNoController.text = student.mobile;
    dobController.text = student.DOB;
    selProgram = student.program;
    selProgramTerm = student.programTerm;
    seldiv = student.division;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${student.userId}'),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ReusableTextField(
                          controller: firstNameController,
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
                          controller: middleNameController,
                          keyboardType: TextInputType.name,
                          readOnly: false,
                          title: 'Middle Name',
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: ReusableTextField(
                          controller: lastNameController,
                          keyboardType: TextInputType.name,
                          readOnly: false,
                          title: 'Last Name',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ReusableTextField(
                          controller: emailController,
                          keyboardType: TextInputType.name,
                          readOnly: false,
                          title: 'Email',
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: ReusableTextField(
                          controller: mobileNoController,
                          maxLength: 10,
                          keyboardType: TextInputType.phone,
                          readOnly: false,
                          title: 'Mobile',
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                          flex: 1,
                          child: ReusableTextField(
                            controller: dobController,
                            OnTap: () => selectDate(context),
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
                          title: const Text(
                            "Program",
                            style: TextStyle(fontSize: 15),
                          ),
                          subtitle: DropdownButtonFormField(
                              validator: (value) {
                                if (value!.isEmpty ||
                                    _selProgram == "--Please Select--") {
                                  return "Please Select Program";
                                }
                              },
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.zero))),
                              value: selProgram,
                              items: _programs
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  selProgram = val as String;
                                });
                              }),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text(
                            "Program Term",
                            style: TextStyle(fontSize: 15),
                          ),
                          subtitle: DropdownButtonFormField(
                              validator: (value) {
                                if (value!.isEmpty ||
                                    _selProgramTerm == "--Please Select--") {
                                  return "Please Select Program Term";
                                }
                              },
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.zero))),
                              value: selProgramTerm,
                              items: _programTerm
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  selProgramTerm = val as String;
                                });
                              }),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text(
                            "Division",
                            style: TextStyle(fontSize: 15),
                          ),
                          subtitle: DropdownButtonFormField(
                              validator: (value) {
                                if (value!.isEmpty ||
                                    _selProgram == '--Please Select--') {
                                  return "Please Select Division";
                                }
                              },
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.zero))),
                              value: seldiv,
                              items: selProgram == "BCA"
                                  ? _Bcadivision.map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      )).toList()
                                  : selProgram == "B-Com"
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
                                  seldiv = val as String;
                                });
                              }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
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
              onPressed: () async {
                final String newFirstName = firstNameController.text;
                final String newMiddleName = middleNameController.text;
                final String newLastName = lastNameController.text;
                final String newEmail = emailController.text;
                final String newMobile = mobileNoController.text;
                final String newDOB = dobController.text;
                final String newProgram = selProgram.toString();
                final String newProgramTerm = selProgramTerm.toString();
                final String newDivision = seldiv.toString();
                if (selProgram != student.program ||
                    selProgramTerm != student.programTerm ||
                    seldiv != student.division ||
                    studentSnapshot.exists) {
                  Map<String, dynamic> studentData = studentSnapshot.data()!;
                  await FirebaseFirestore.instance
                      .collection('students')
                      .doc(student.program)
                      .collection(student.programTerm)
                      .doc(student.division)
                      .collection('student')
                      .doc(userId)
                      .delete();

                  await FirebaseFirestore.instance
                      .collection('students')
                      .doc(newProgram)
                      .collection(newProgramTerm)
                      .doc(newDivision)
                      .collection('student')
                      .doc(userId)
                      .set(studentData);

                  FirebaseFirestore.instance
                      .collection('students')
                      .doc(newProgram)
                      .collection(newProgramTerm)
                      .doc(newDivision)
                      .collection('student')
                      .doc(userId)
                      .update({
                    'First Name': newFirstName,
                    'Middle Name': newMiddleName,
                    'Last Name': newLastName,
                    'Mobile': newMobile,
                    'Email': newEmail,
                    'program': newProgram,
                    'programTerm': newProgramTerm,
                    'division': newDivision,
                    'DOB': newDOB
                  });
                } else {
                  FirebaseFirestore.instance
                      .collection('students')
                      .doc(program)
                      .collection(programTerm)
                      .doc(Division)
                      .collection('student')
                      .doc(userId)
                      .update({
                    'First Name': newFirstName,
                    'Middle Name': newMiddleName,
                    'Last Name': newLastName,
                    'Mobile': newMobile,
                    'Email': newEmail,
                    'program': newProgram,
                    'programTerm': newProgramTerm,
                    'division': newDivision,
                    'DOB': newDOB
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}

// void _showUpdateDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Update Student Details'),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               decoration: InputDecoration(labelText: 'Name'),
//             ),
//             TextField(
//               decoration: InputDecoration(labelText: 'Age'),
//               keyboardType: TextInputType.number,
//             ),
//             TextField(
//               decoration: InputDecoration(labelText: 'Address'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               _updateStudentDetails(_sele);
//               Navigator.of(context).pop();
//             },
//             child: const Text('Submit'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: const Text('Close'),
//           ),
//         ],
//       );
//     },
//   );
// }

void _confirmDelete(BuildContext context, String program, String programTerm,
    String division, String userId) {
  TextEditingController _passwordController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your password to confirm deletion:'),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_passwordController.text == 'superAdmin') {
                DeleteStudent(program, programTerm, division, userId);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      backgroundColor: Colors.white,
                      shape: ContinuousRectangleBorder(),
                      content: Text(
                        'Invalid password',
                        style: TextStyle(color: Colors.black),
                      )),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}
