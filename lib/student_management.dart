import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecollege_admin_panel/reusable_widget/reusable_textfield.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdmissionForm extends StatefulWidget {
  @override
  _AdmissionFormState createState() => _AdmissionFormState();
}

class _AdmissionFormState extends State<AdmissionForm> {
  final CollectionReference _db =
      FirebaseFirestore.instance.collection('students');
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
  final TextEditingController _rollNo = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();

  void _handleFileUpload(html.File file) {
    setState(() {
      _fileNameController.text = file.name;
    });
  }
  Map<String,dynamic> data={

  };

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
      body:
      SingleChildScrollView(
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
                                          onPressed: () {
                                            html.FileUploadInputElement
                                                uploadInput =
                                                html.FileUploadInputElement()
                                                  ..accept = 'image/*';
                                            uploadInput.click();
                                            uploadInput.onChange
                                                .listen((event) {
                                              final files = uploadInput.files;
                                              if (files != null &&
                                                  files.length == 1) {
                                                final file = files[0];
                                                _handleFileUpload(file);
                                              }
                                            });
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
                            controller: _rollNo,
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
                            "Email": _emailController.text,
                            "Mobile": _phoneController.text,
                            "DOB": _dobController.text,
                            "Program": _selProgram.toString(),
                            "Program Term": _selProgramTerm.toString(),
                            "Division": _seldiv.toString()
                            });
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          )),
                    ),
                  ],
                ),
              ),
              Text("")
            ],
          ),
        ),
      ),
    );
  }
}
