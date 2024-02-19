import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Home extends StatelessWidget {
  const Home({super.key});

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
                            "5",
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
