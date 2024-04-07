import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecollege_admin_panel/copyright_2024.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

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

int _totalStudent = 0;
int _totalFaculty = 0;

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

String _getGreeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good Morning, Admin!';
  } else if (hour < 18) {
    return 'Good Afternoon, Admin!';
  } else {
    return 'Good Evening, Admin!';
  }
}

class _HomeState extends State<Home> {
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');
  late DocumentReference _UserIdDoc;
  late DocumentReference _IdDoc;
  late TextEditingController _totalStudentsController = TextEditingController();
  late TextEditingController _totalFacultyController = TextEditingController();

  void initState() {
    super.initState();
    _UserIdDoc =
        FirebaseFirestore.instance.collection('metadata').doc('userId');
    _getUserId();
    _IdDoc = FirebaseFirestore.instance.collection('metadata').doc('FacultyId');
    _getUserId();
    _totalStudentsController = TextEditingController();
    _totalFacultyController = TextEditingController();
  }

  Future<void> _getUserId() async {
    final userIdDocSnapshot = await _UserIdDoc.get();
    final IdDocSnapshot = await _IdDoc.get();

    setState(() {
      _totalStudent =
          userIdDocSnapshot.exists && userIdDocSnapshot.data() != null
              ? (userIdDocSnapshot.data()
                      as Map<String, dynamic>)['Total Students'] ??
                  0
              : 0;
      _totalStudentsController.text = _totalStudent.toString();

      _totalFaculty = IdDocSnapshot.exists && IdDocSnapshot.data() != null
          ? (IdDocSnapshot.data() as Map<String, dynamic>)['Total Faculty'] ?? 0
          : 0;
      _totalFacultyController.text = _totalFaculty.toString();
    });
  }

  void dispose() {
    _totalStudentsController.dispose();
    _totalFacultyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'DASHBOARD',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Expanded(
            child: Column(
              children: [
                _userData(),
                _buildEventList(),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildEventList() {
    int rowIndex = 0; // Initialize the row index

    return StreamBuilder<QuerySnapshot>(
      stream: eventsCollection
          .where('assignTo',
              arrayContains: 'Dashboard') // Filter events by assignTo value
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
                  child: Text("No Announcement Published On Dashboard"),
                )
              : Container(
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
                            width: 150,
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
              ),
        );
      },
    );
  }
}

Widget _userData() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Expanded(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 200,
          child: Card(
            elevation: 5,
            shape: const ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            color: Colors.green.shade300,
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: ListTile(
                title: const Text(
                  "Total Students",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                subtitle: Text(
                  _totalStudent.toString(),
                  style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      )),
      Expanded(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 200,
          child: Card(
            elevation: 5,
            shape: const ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            color: Colors.blueAccent.shade100,
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: ListTile(
                title: const Text(
                  "Total Faculty",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                subtitle: Text(
                  _totalFaculty.toString(),
                  style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      )),
      Expanded(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 200,
          child: Card(
            elevation: 5,
            shape: const ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            color: _getGreeting() == "Good Morning, Admin!"
                ? Colors.deepOrange.shade300
                : _getGreeting() == "Good Afternoon, Admin!"
                    ? Colors.orange.shade300
                    : Colors.blue.shade300,
            child: Padding(
              padding: EdgeInsets.all(50),
              child: Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      )),
    ],
  );
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E element) f) sync* {
    var index = 0;
    for (final element in this) {
      yield f(index++, element);
    }
  }
}
