import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late DocumentReference _UserIdDoc;

  late TextEditingController _totalStudentsController = TextEditingController();

  int _totalStudent = 0;

  void initState() {
    super.initState();
    _UserIdDoc =
        FirebaseFirestore.instance.collection('metadata').doc('userId');
    _getUserId();
    _totalStudentsController = TextEditingController();
  }

  Future<void> _getUserId() async {
    final userIdDocSnapshot = await _UserIdDoc.get();
    setState(() {
      _totalStudent =
      userIdDocSnapshot.exists && userIdDocSnapshot.data() != null
          ? (userIdDocSnapshot.data()
      as Map<String, dynamic>)['Total Students'] ??
          0
          : 0;
      _totalStudentsController.text = _totalStudent.toString();
    });
  }
  void dispose() {
    _totalStudentsController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                FontAwesomeIcons.houseChimney,
                color: Color(0xff002233),
              ),
              title: Text(
                "Dashboard",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Row(
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
                            style: TextStyle(
                                fontSize: 20,color: Colors.white),
                          ),
                          subtitle: Text(
                            _totalStudent.toString(),
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold,color: Colors.white),
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
                      color: Colors.deepOrange.shade300,
                      child: Text("89"),
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
                      color: Colors.grey.shade200,
                      child: Text("89"),
                    ),
                  ),
                ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
