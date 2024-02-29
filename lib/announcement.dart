import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ecollege_admin_panel/reusable_widget/reusable_textfield.dart';
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
  final DateTime date;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.assignTo,
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
  List<ValueItem> _selectedOptions = [];

  void initState() {
    super.initState();
  }

  ScrollController _dataController1 = ScrollController();
  ScrollController _dataController2 = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        children: [
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  void  _buildEventForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context){
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
                              ValueItem(label: 'Dashboard', value: 'Dashboard'),
                              ValueItem(label: 'BCA', value: 'BCA'),
                              ValueItem(label: 'BBA', value: 'BBA'),
                              ValueItem(label: 'B-Com', value: 'B-Com'),
                            ],
                            selectionType: SelectionType.multi,
                            chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                            dropdownHeight: 300,
                            optionTextStyle: const TextStyle(fontSize: 16),
                            selectedOptionIcon: const Icon(Icons.check_circle),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // _selectedOptions.clear();
                        // _selectedOptions.addAll(_controller.selectedOptions);
                        final String AssignTo =
                        _selectedOptions.map((item) => item.value).join(',');
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
      }
     );
  }

  Widget _buildEventList() {
    return StreamBuilder<QuerySnapshot>(
      stream: eventsCollection.orderBy('date', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: const CircularProgressIndicator());
        }

        final events = snapshot.data;
        if (events == null || events.docs.isEmpty) {
          return Center(
            child: const Text('No Events found'),
          );
        }

        return ListView.builder(
          itemCount: events.docs.length,
          itemBuilder: (BuildContext context, int index) {
            final event = events.docs[index];
            final eventData = event.data() as Map<String, dynamic>;
            final Timestamp timestamp = eventData['date'];
            final DateTime date = timestamp.toDate();
            String _month = DateFormat('MMM').format(date);

            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: ListTile(
                leading: Column(
                  children: [
                    Text(_month,style: TextStyle(color: Color(0xff4b8fbf),fontWeight: FontWeight.bold,fontSize: 15),),
                    Text('${date.day}',style: TextStyle(color: Color(0xff002233),fontWeight: FontWeight.bold,fontSize: 15),)
                  ],
                ),
                title: Text(eventData['title'] ?? 'Title not available'),
                subtitle: ReadMoreText(
                  eventData['description'] ??
                      'Description not available',
                  style: TextStyle(color: Colors.black),
                  colorClickableText: Colors.grey,
                  trimLines: 2,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: 'Read more',
                  trimExpandedText: '^Read less',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.edit,
                        color: Colors.green.shade300,
                      ),
                      onPressed: () => _editEvent(events as Event),
                    ),
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.trash,
                        color: Colors.redAccent.shade400,
                      ),
                      onPressed: () => _deleteEvent(event.id),
                    ),
                  ],
                ),
              ),
            );
          },
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
    );
    eventsCollection.add({
      'title': newEvent.title,
      'description': newEvent.description,
      'date': newEvent.date,
      'assign To': newEvent.assignTo
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
