import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ecollege_admin_panel/copyright_2024.dart';
import 'package:ecollege_admin_panel/reusable_widget/reusable_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:readmore/readmore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String assignTo;
  final String Files;
  final DateTime date;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.assignTo,
    required this.Files,
    required this.date,
  });
}

class EventManagement extends StatefulWidget {
  @override
  _EventManagementState createState() => _EventManagementState();
}

class _EventManagementState extends State<EventManagement> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _controller = MultiSelectController();
  final _filenameController = TextEditingController();
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  late String imjUrl;
  List<ValueItem> _selectedOptions = [];

  void initState() {
    super.initState();
  }

  ScrollController _dataController1 = ScrollController();
  ScrollController _dataController2 = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CopyrightFooter(),
      appBar: AppBar(
        title: Text('Event List'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () {
                  _buildEventForm(context);
                },
                icon: Icon(
                  FontAwesomeIcons.add,
                  color: Color(0xff002233),
                )),
          )
        ],
      ),
      body: Column(
        children: [Expanded(child: _buildEventList())],
      ),
    );
  }

  void _buildEventForm(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableTextField(
                      title: 'Title',
                      controller: _titleController,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ReusableTextField(
                      isMulti: true,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      title: 'Description',
                      controller: _descriptionController,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text(
                              "Assign To",
                              style: TextStyle(fontSize: 15),
                            ),
                            subtitle: MultiSelectDropDown(
                              showClearIcon: true,
                              controller: _controller,
                              hint: 'Please Select',
                              onOptionSelected: (value) {
                                setState(() {
                                  _selectedOptions = value;
                                });
                              },
                              options: const <ValueItem>[
                                ValueItem(
                                    label: 'Dashboard', value: 'Dashboard'),
                                ValueItem(label: 'BCA', value: 'BCA'),
                                ValueItem(label: 'BBA', value: 'BBA'),
                                ValueItem(label: 'B-Com', value: 'B-Com'),
                              ],
                              selectionType: SelectionType.multi,
                              chipConfig:
                                  const ChipConfig(wrapType: WrapType.wrap),
                              dropdownHeight: 300,
                              optionTextStyle: const TextStyle(fontSize: 16),
                              selectedOptionIcon:
                                  const Icon(Icons.check_circle),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Column(
                          children: [
                            ReusableTextField(
                              readOnly: true,
                              controller: _filenameController,
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
                                      var result = await FilePicker.platform
                                          .pickFiles(
                                              allowMultiple: true,
                                              type: FileType.image);
                                      if (result == null) {
                                        print("Error: No file selected");
                                      } else {
                                        var path = result.files.single.bytes;
                                        final fileName =
                                            result.files.single.name;

                                        setState(() {
                                          _filenameController.text = fileName;
                                          result = null;
                                        });

                                        try {
                                          await firebaseStorage
                                              .ref('Notice/$fileName')
                                              .putData(path!)
                                              .then((p0) async {
                                            log("Uploaded");
                                          });
                                        } catch (e) {
                                          log("Error: $e");
                                        }
                                        var imgurl = await firebaseStorage
                                            .ref('Notice/$fileName')
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
                                          color: Colors.white, fontSize: 15),
                                    )),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // _selectedOptions.clear();
                          // _selectedOptions.addAll(_controller.selectedOptions);
                          final String AssignTo = _selectedOptions
                              .map((item) => item.value)
                              .join(',');
                          _addEvent(AssignTo);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('Add Event'),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildEventList() {
    int rowIndex = 0; // Initialize the row index

    return StreamBuilder<QuerySnapshot>(
      stream: eventsCollection
          // Filter events by assignTo value
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data;
        if (events == null) {
          return const Center(
            child: Text('No Events found'),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: events.docs.isEmpty
              ? Center(
                  child: Text("No Announcement Published"),
                )
              : DataTable(
                  border: TableBorder.all(color: Colors.black),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'No.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Add column for row number
                    DataColumn(
                      label: Text(
                        'Title',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Assign To',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  columnSpacing: 20,
                  dataRowMaxHeight: double.infinity,
                  // Adjust the spacing between columns
                  rows: events.docs.map((event) {
                    final eventData = event.data() as Map<String, dynamic>;
                    final Timestamp timestamp =
                        eventData['date']; // Get the Timestamp
                    final DateTime date = timestamp.toDate();
                    final _date = DateFormat('dd-MM-yyyy hh:mm a')
                        .format(date); // Convert to DateTime
                    rowIndex++; // Increment row index for each row

                    return DataRow(cells: [
                      DataCell(
                        Text(
                          '$rowIndex',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ), // Display the row index
                      ),
                      DataCell(
                        Container(
                          child: Text(
                            eventData['title'] ?? 'Title not available',
                            // Null check
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${eventData['description']}',
                          ),
                        ),
                      ),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${eventData['assignTo']}',
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '$_date',
                          style: const TextStyle(
                            color: Color(0xff4b8fbf),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
        );
      },
    );
  }

  void _addEvent(String assignTo) {
    final newEvent = Event(
      id: '',
      title: _titleController.text,
      description: _descriptionController.text,
      date: DateTime.now(),
      assignTo: assignTo,
      Files: imjUrl.toString(),
    );
    eventsCollection.add({
      'title': newEvent.title,
      'description': newEvent.description,
      'date': newEvent.date,
      'assignTo': newEvent.assignTo
    });
    _titleController.clear();
    _descriptionController.clear();
  }

  void _editEvent(Event event) {
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReusableTextField(
                title: 'Title',
                controller: _titleController,
              ),
              ReusableTextField(
                isMulti: true,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                title: 'Description',
                controller: _descriptionController,
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
                eventsCollection.doc(event.id).update({
                  'title': _titleController.text,
                  'description': _descriptionController.text,
                });
                Navigator.of(context).pop();
                _titleController.clear();
                _descriptionController.clear();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _deleteEvent(String eventId) {
    AwesomeDialog(
      width: 400,
      context: context,
      dialogType: DialogType.question,
      btnOkOnPress: () async {
        await eventsCollection.doc(eventId).delete();
        // for snackBar
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Deleted")));
      },
      showCloseIcon: true,
      title: "Are You Sure?",
    ).show();
  }
}
