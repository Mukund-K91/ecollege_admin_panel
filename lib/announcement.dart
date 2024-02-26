import 'package:ecollege_admin_panel/reusable_widget/reusable_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';

class Event {
  final String title;
  final String description;
  final DateTime date;

  Event({
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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late List<Event> events;
  late Map<String, bool> isExpandedMap;

  @override
  void initState() {
    super.initState();
    events = [];
    isExpandedMap = {};
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('events').get();

      setState(() {
        events = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return Event(
            title: data['title'],
            description: data['description'],
            date: (data['date'] as Timestamp).toDate(),
          );
        }).toList();
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  Future<void> addEvent(Event event) async {
    try {
      await FirebaseFirestore.instance.collection('events').add({
        'title': event.title,
        'description': event.description,
        'date': event.date,
      });
      fetchEvents(); // Refresh the events list
    } catch (e) {
      print('Error adding event: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Announcement'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReusableTextField(
                    title: 'Title',
                    controller: _titleController,
                  ),
                  ReusableTextField(
                    controller: _descriptionController,
                    title: 'Description',
                    isMulti: true,
                    keyboardType: TextInputType.multiline,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final newEvent = Event(
                        title: _titleController.text,
                        description: _descriptionController.text,
                        date: DateTime.now(),
                      );
                      addEvent(newEvent);
                    },
                    child: Text('Add Event'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                Event event = events[index];
                bool isExpanded = isExpandedMap[event.title] ?? false;
                String _date=DateFormat('dd-MMMM-yyyy').format(event.date);

                return Column(
                  children: [
                    ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '${event.date.day}',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            '${event.date.month}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      title: Text(event.title),
                      subtitle: ReadMoreText(
                        '${event.description}',
                        trimCollapsedText: 'Show More',
                        style: TextStyle(color: Colors.black),
                        trimMode: TrimMode.Line,
                        colorClickableText: Colors.grey,
                        trimExpandedText: '-Show less',
                      ),
                      trailing:SizedBox(
                        width: 150,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: Icon(FontAwesomeIcons.edit,color: Colors.green,)),
                            IconButton(
                                onPressed: () {},
                                icon: Icon(FontAwesomeIcons.trash,color: Colors.redAccent,)),
                          ],
                        ),
                      ),
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: EventListPage(),
  ));
}
