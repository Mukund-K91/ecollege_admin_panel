import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ecollege_admin_panel/reusable_widget/reusable_textfield.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });
}

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
      ),
      body: Column(
        children: [
          _buildEventForm(),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  Widget _buildEventForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _addEvent,
            child: Text('Add Event'),
          ),
        ],
      ),
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

        List<Event> events = snapshot.data!.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Event(
            id: doc.id,
            title: data['title'],
            description: data['description'],
            date: (data['date'] as Timestamp).toDate(),
          );
        }).toList();

        return ListView.separated(
          itemCount: events.length,
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey,
          ),
          itemBuilder: (context, index) {
            Event event = events[index];
            String _month = DateFormat('MMM').format(event.date);
            return ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_month}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xff002233)),
                  ),
                  Text(
                    '${event.date.day}',
                    style: TextStyle(
                        color: Color(0xff4b8fbf),
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ],
              ),
              title: Text(event.title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black)),
              subtitle: ReadMoreText(
                event.description,
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
                    onPressed: () => _editEvent(event),
                  ),
                  IconButton(
                    icon: Icon(
                      FontAwesomeIcons.trash,
                      color: Colors.redAccent.shade400,
                    ),
                    onPressed: () => _deleteEvent(event),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _addEvent() {
    final newEvent = Event(
      id: '',
      title: _titleController.text,
      description: _descriptionController.text,
      date: DateTime.now(),
    );
    eventsCollection.add({
      'title': newEvent.title,
      'description': newEvent.description,
      'date': newEvent.date,
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

  void _deleteEvent(Event event) {
    AwesomeDialog(
      width: 400,
      context: context,
      dialogType: DialogType.question,
      btnOkOnPress: () async {
        await eventsCollection.doc(event.id).delete();
        // for snackBar
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Deleted")));
      },
      showCloseIcon: true,
      title: "Are You Sure?",
    ).show();
  }
}

void main() {
  runApp(MaterialApp(
    home: EventListPage(),
  ));
}
