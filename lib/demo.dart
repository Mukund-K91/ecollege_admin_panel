// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// void main() {
//   runApp(StudentList());
// }
//
// class StudentList extends StatefulWidget {
//   @override
//   _StudentListState createState() => _StudentListState();
// }
//
// class Student {
//   final String name;
//   final String className;
//
//   Student({required this.name, required this.className});
// }
//
// class _StudentListState extends State<StudentList> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   late List<Student> _students;
//   late List<Student> _filteredStudents;
//   late String _selectedClass;
//   late TextEditingController _searchController;
//
//   @override
//   void initState() {
//     super.initState();
//     _students = [];
//     _filteredStudents = [];
//     _selectedClass = 'All';
//     _searchController = TextEditingController();
//     _fetchStudents();
//   }
//
//   Future<void> _fetchStudents() async {
//     final QuerySnapshot<Map<String, dynamic>> querySnapshot =
//     await _firestore.collection('students').get();
//     final List<Student> students = querySnapshot.docs.map((doc) {
//       return Student(
//         name: doc['First Name'],
//         className: doc['Division'],
//       );
//     }).toList();
//     setState(() {
//       _students = students;
//       _filteredStudents = _students;
//     });
//   }
//
//   void _filterStudents() {
//     setState(() {
//       _filteredStudents = _students.where((student) {
//         if (_selectedClass == 'All' || student.className == _selectedClass) {
//           final query = _searchController.text.toLowerCase();
//           return student.name.toLowerCase().contains(query);
//         }
//         return false;
//       }).toList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Student List',
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Student List'),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   DropdownButton<String>(
//                     value: _selectedClass,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedClass = value!;
//                         _filterStudents();
//                       });
//                     },
//                     items: ['All', 'A', 'B']
//                         .map((className) => DropdownMenuItem<String>(
//                       value: className,
//                       child: Text(className),
//                     ))
//                         .toList(),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: TextField(
//                       controller: _searchController,
//                       onChanged: (value) => _filterStudents(),
//                       decoration: InputDecoration(
//                         hintText: 'Search by name',
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),
//               Expanded(
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: DataTable(
//                     columns: [
//                       DataColumn(label: Text('Name')),
//                       DataColumn(label: Text('Class')),
//                     ],
//                     rows: _filteredStudents.map((student) {
//                       return DataRow(
//                         cells: [
//                           DataCell(Text(student.name)),
//                           DataCell(Text(student.className)),
//                         ],
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImageAndMore extends StatefulWidget {
  const UploadImageAndMore({super.key});

  @override
  State<UploadImageAndMore> createState() => _UploadImageAndMoreState();
}

class _UploadImageAndMoreState extends State<UploadImageAndMore> {
  // text fiedl controller
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  final CollectionReference _items =
  FirebaseFirestore.instance.collection("Upload_Items");
  // collection name must be same as firebase collection name

  String imageUrl = '';

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                right: 20,
                left: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text("Create your Items"),
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Name', hintText: 'eg Elon'),
                ),
                TextField(
                  controller: _numberController,
                  decoration: const InputDecoration(
                      labelText: 'Number', hintText: 'eg 10'),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                    child: IconButton(
                        onPressed: () async {
                          // add the package image_picker
                          final file = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (file == null) return;

                          String fileName =
                          DateTime.now().microsecondsSinceEpoch.toString();

                          // Get the reference to storage root
                          // We create the image folder first and insider folder we upload the image
                          Reference referenceRoot =
                          FirebaseStorage.instance.ref();
                          Reference referenceDireImages =
                          referenceRoot.child('Profiles');

                          // we have creata reference for the image to be stored
                          Reference referenceImageaToUpload =
                          referenceDireImages.child(fileName);

                          // For errors handled and/or success
                          try {
                            await referenceImageaToUpload
                                .putFile(File(file.path));

                            // We have successfully upload the image now
                            // make this upload image link in firebase database

                            imageUrl =
                            await referenceImageaToUpload.getDownloadURL();
                          } catch (error) {
                            //some error
                          }
                        },
                        icon: const Icon(Icons.camera_alt))),
                Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          if (imageUrl.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Please select and upload image")));
                            return;
                          }
                          final String name = _nameController.text;
                          final int? number =
                          int.tryParse(_numberController.text);
                          if (number != null) {
                            await _items.add({
                              // Add items in you firebase firestore
                              "name": name,
                              "number": number,
                              "image": imageUrl,
                            });
                            _nameController.text = '';
                            _numberController.text = '';
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Create')))
              ],
            ),
          );
        });
  }

  late Stream<QuerySnapshot> _stream;
  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance.collection('Upload_Items').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload and display Items"),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Some error occured${snapshot.error}"),
              );
            }
            // Now , Cheeck if datea arrived?
            if (snapshot.hasData) {
              QuerySnapshot querySnapshot = snapshot.data;
              List<QueryDocumentSnapshot> document = querySnapshot.docs;

              // We need to Convert your documnets to Maps to display
              List<Map> items = document.map((e) => e.data() as Map).toList();

              //At Last, Display the list of items
              return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map thisItems = items[index];
                    return ListTile(
                        title: Text(
                          "${thisItems['name']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        subtitle: Text("${thisItems['number']}"),
                        leading: CircleAvatar(
                          radius: 27,
                          child: thisItems.containsKey('image')
                              ? ClipOval(
                            child: Image.network(
                              "${thisItems['image']}",
                              fit: BoxFit.cover,
                              height: 70,
                              width: 70,
                            ),
                          )
                              : const CircleAvatar(),
                        ));
                  });
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _create();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}