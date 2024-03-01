import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
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

int _totalStudent = 0;
int _totalFaculty = 0;
ScrollController _dataController1 = ScrollController();
ScrollController _dataController2 = ScrollController();

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
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
          title: Text(
            'DASHBOARD',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [_userData(), Expanded(child: _buildEventList())],
        )
        //_buildEventList()
        );
  }

  Widget _buildEventList() {
    int rowIndex = 0; // Initialize the row index

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
        if (events == null) {
          return const Center(
            child: Text('No Events found'),
          );
        }

        return DataTable(
          columns: const [
            DataColumn(label: Text('No.')), // Add column for row number
            DataColumn(label: Text('Title')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Date')),
          ],
          columnSpacing: 20, // Adjust the spacing between columns
          rows: events.docs.map((event) {
            final eventData = event.data() as Map<String, dynamic>;
            final Timestamp timestamp = eventData['date']; // Get the Timestamp
            final DateTime date = timestamp.toDate(); // Convert to DateTime
            String _month = DateFormat('MMM').format(date);
            rowIndex++; // Increment row index for each row
            return DataRow(cells: [
              DataCell(
                Text('$rowIndex'), // Display the row index
              ),
              DataCell(
                Container(
                  width: 250, // Adjust the width of the column
                  child: Text(
                    eventData['title'] ?? 'Title not available',
                    // Null check
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              DataCell(

                Container(
                    width: 600,
                    child:
                    SingleChildScrollView(child:Text(
                      '${eventData['description']}',
                      overflow: TextOverflow.clip,
                      // softWrap: false,
                      maxLines: 4,
                    ) ,)

                  // Tooltip(
                  //   enableTapToDismiss: true,
                  //   message: eventData['description'],
                  //   child: Text('${eventData['description']}'),
                  // )
                ),
              ),
              DataCell(
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_month}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xff002233),
                      ),
                    ),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: Color(0xff4b8fbf),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(),
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
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            color: Colors.green.shade300,
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: ListTile(
                title: Text(
                  "Total Students",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                subtitle: Text(
                  _totalStudent.toString(),
                  style: TextStyle(
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
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            color: Colors.blueAccent.shade100,
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: ListTile(
                title: Text(
                  "Total Faculty",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                subtitle: Text(
                  _totalFaculty.toString(),
                  style: TextStyle(
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
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            color: Colors.red.shade200,
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: Text(
                'heloo',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
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
