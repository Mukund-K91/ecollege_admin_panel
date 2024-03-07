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
import 'dart:html' as html;
import 'package:path/path.dart' as path;

class Event {
  final String id;
  final String title;
  final String description;
  final String assignTo;
  final String? Files;
  final String? FileName;
  final DateTime date;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.assignTo,
    this.Files,
    this.FileName,
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
  final _filenameController = TextEditingController(text: "-");
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  late String imjUrl="null";
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
                            TextFormField(
                              readOnly: false,
                              controller: _filenameController,
                              decoration: InputDecoration(
                                label: Text("Uploade"),
                                suffixIcon: Padding(
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
                                            type: FileType.any);
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
                                      },
                                      child: const Text(
                                        "Upload",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      )),
                                ),
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
    ScrollController _dataController1 = ScrollController();
    ScrollController _dataController2 = ScrollController();

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
              : SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: DataTable(
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
                          'Files',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Action',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    columnSpacing: 20,
                    dataRowMaxHeight: double.infinity,
                    // Adjust the spacing between columns
                    rows: events.docs.map((event) {
                      final eventData =
                          event.data() as Map<String, dynamic>;
                      final Timestamp timestamp =
                          eventData['date']; // Get the Timestamp
                      final DateTime date = timestamp.toDate();
                      final _date = DateFormat('dd-MM-yyyy \nhh:mm')
                          .format(date); // Convert to DateTime
                      final _time = DateFormat('hh:mm').format(date);
                      rowIndex++; // Increment row index for each row
                      String fileUrl = eventData['File'];
                      String fileName = path.basename(fileUrl);
                
                      return DataRow(cells: [
                        DataCell(
                          Text(
                            '$rowIndex',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ), // Display the row index
                        ),
                        DataCell(
                          Container(
                            width:
                                MediaQuery.of(context).size.width / 10,
                            child: Text(
                              eventData['title'] ??
                                  'Title not available',
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
                          Container(
                            width:
                                MediaQuery.of(context).size.width / 5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${eventData['description']}',
                              ),
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
                            fileUrl.toString()!="null"?InkWell(
                            onTap: () {
                              String fileUrl = eventData['File'];
                              html.AnchorElement anchor =
                                  html.AnchorElement(href: fileUrl);
                              anchor.target = 'fileViewer';
                              anchor.click();
                            },
                            child: Text(
                              // Extract the file name from the URL
                              eventData['FileName']??'-',
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ): Text(
                              // Extract the file name from the URL
                              'No file',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                        ),
                        // DataCell(
                        //   Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: Text(
                        //       '${eventData['File']}',
                        //     ),
                        //   ),
                        // ),
                        DataCell(
                          Text(
                            "${_date}",
                            style: const TextStyle(
                              color: Color(0xff4b8fbf),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        DataCell(Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  _editEvent(
                                    Event(
                                        id: event.id,
                                        title: eventData['title'],
                                        description:
                                            eventData['description'],
                                        assignTo: eventData['assignTo'],
                                        date: date,
                                        Files: eventData['File'],
                                        FileName:
                                            eventData['FileName']),
                                  );
                                },
                                icon: const Icon(
                                  FontAwesomeIcons.edit,
                                  color: Colors.green,
                                )),
                            IconButton(
                                onPressed: () => _deleteEvent(event.id),
                                icon: const Icon(
                                  FontAwesomeIcons.trash,
                                  color: Colors.redAccent,
                                )),
                          ],
                        ))
                      ]);
                    }).toList(),
                  ),
                ),
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
      Files: imjUrl.toString(), FileName: _filenameController.text,
    );
    eventsCollection.add({
      'title': newEvent.title,
      'description': newEvent.description,
      'date': newEvent.date,
      'assignTo': newEvent.assignTo,
      'File': newEvent.Files,
      'FileName':newEvent.FileName
    });
    Navigator.of(context).pop();
    _titleController.clear();
    _descriptionController.clear();
    _filenameController.clear();
  }

  void _editEvent(Event event) {
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          width: double.infinity,
          child: AlertDialog(
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
          ),
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
