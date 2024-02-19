import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecollege_admin_panel/reusable_widget/reusable_textfield.dart';
import 'package:ecollege_admin_panel/storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AddStudents extends StatefulWidget {
  @override
  _AddStudentsState createState() => _AddStudentsState();
}

class _AddStudentsState extends State<AddStudents> {
  final CollectionReference _db =
      FirebaseFirestore.instance.collection('students');

  final TextEditingController _searchController = TextEditingController();
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  StorageService service = StorageService();

  StorageService storageService = StorageService();
  late CollectionReference _studentsCollection;
  late DocumentReference _rollNumberDoc;
  int _lastRollNumber = 101;
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
  late TextEditingController _rollNumberController;
  final TextEditingController _dobController = TextEditingController();
  late TextEditingController _fileNameController = TextEditingController();
  late TextEditingController _totalStudentsController = TextEditingController();

  void initState() {
    super.initState();
    _studentsCollection = _db;
    _rollNumberDoc =
        FirebaseFirestore.instance.collection('metadata').doc('rollNumber');
    _getRollNumber();
    _rollNumberController = TextEditingController();
    _totalStudentsController = TextEditingController();
  }

  Future<void> _getRollNumber() async {
    final rollNumberDocSnapshot = await _rollNumberDoc.get();
    setState(() {
      _lastRollNumber =
          rollNumberDocSnapshot.exists && rollNumberDocSnapshot.data() != null
              ? (rollNumberDocSnapshot.data()
                      as Map<String, dynamic>)['lastRollNumber'] ??
                  101
              : 101;
      _rollNumberController.text = _lastRollNumber.toString();
      _totalStudent =
          rollNumberDocSnapshot.exists && rollNumberDocSnapshot.data() != null
              ? (rollNumberDocSnapshot.data()
                      as Map<String, dynamic>)['Total Students'] ??
                  0
              : 0;
      _totalStudentsController.text = _totalStudent.toString();
    });
  }

  Future<void> _incrementRollNumber() async {
    _lastRollNumber++;
    _totalStudent++;
    await _rollNumberDoc.set(
        {'lastRollNumber': _lastRollNumber, 'Total Students': _totalStudent});
  }

  @override
  void dispose() {
    _rollNumberController.dispose();
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
                            controller: _rollNumberController,
                            maxLength: 10,
                            keyboardType: TextInputType.phone,
                            readOnly: true,
                            title: 'Roll No.',
                          ),
                        ),
                        Expanded(
                          child: ReusableTextField(
                            controller: _totalStudentsController,
                            maxLength: 10,
                            keyboardType: TextInputType.phone,
                            readOnly: true,
                            title: 'Roll No.',
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
                            await _db.add({
                              "First Name": _firstNameController.text,
                              "Middle Name": _middleNameController.text,
                              "Last Name": _lastNameController.text,
                              "Gender": _selectedGender.toString(),
                              "Profile": _fileNameController.text,
                              "Roll No": _lastRollNumber,
                              "Image": imjUrl,
                              "Email": _emailController.text,
                              "Mobile": _phoneController.text,
                              "DOB": _dobController.text,
                              "Program": _selProgram.toString(),
                              "Program Term": _selProgramTerm.toString(),
                              "Division": _seldiv.toString()
                            });
                            _firstNameController.text = "";
                            _fileNameController.text = "";
                            _middleNameController.text = "";
                            _lastNameController.text = "";
                            _selectedGender = "";
                            _emailController.text = "";
                            _phoneController.text = "";
                            _dobController.text = "";
                            _selProgram = "--Please Select--";

                            await _incrementRollNumber();
                            // Update TextField value after increment
                            _rollNumberController.text =
                                _lastRollNumber.toString();
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
  @override
  _StudentListState createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  late TextEditingController _searchController;
  late String _selectedProgram = '--Program--';
  late String _selectedProgramTerm = '--Program Term';
  late String _selectedClass = '--Division--';

  @override
  void initState() {
    super.initState();
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
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {});
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
            value: _selectedClass,
            onChanged: (String? value) {
              setState(() {
                _selectedClass = value!;
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .orderBy('Roll No')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<DocumentSnapshot> students = snapshot.data!.docs;

        // Filter students based on selected program
        if (_selectedProgram.isNotEmpty) {
          students = students.where((student) {
            return student['Program'] == _selectedProgram;
          }).toList();
        }

        // Filter students based on selected program term
        if (_selectedProgramTerm.isNotEmpty) {
          students = students.where((student) {
            return student['Program Term'] == _selectedProgramTerm;
          }).toList();
        }

        // Filter students based on selected class
        if (_selectedClass.isNotEmpty) {
          students = students.where((student) {
            return student['Division'] == _selectedClass;
          }).toList();
        }

        // Filter students based on search query
        if (_searchController.text.isNotEmpty) {
          final searchQuery = _searchController.text.toLowerCase();
          students = students.where((student) {
            return student['Roll No'].toLowerCase().contains(searchQuery);
          }).toList();
        }

        if (students.isEmpty) {
          return Center(
            child: Text('No data found'),
          );
        }

        return DataTable(
          columns: [
            DataColumn(label: Text('Roll No')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Program')),
            DataColumn(label: Text('Program Term')),
            DataColumn(label: Text('Class')),
          ],
          rows: students.map((student) {
            return DataRow(cells: [
              DataCell(Text(student['Roll No'].toString())),
              DataCell(Text(student['First Name'])),
              DataCell(Text(student['Program'])),
              DataCell(Text(student['Program Term'])),
              DataCell(Text(student['Division'])),
            ]);
          }).toList(),
        );
      },
    );
  }
}
