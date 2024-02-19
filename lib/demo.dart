import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentListScreen extends StatefulWidget {
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  late TextEditingController _searchController;
  String _selectedProgram = '--Program--';
  String _selectedProgramTerm = '--Program Term--';
  String _selectedClass = '--Division--';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student List'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildStudentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),
          SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedProgram,
            onChanged: (String? value) {
              setState(() {
                _selectedProgram = value!;
                _selectedProgramTerm = '';
              });
            },
            items: ['--Program--', 'BCA', 'BBA', 'B-Com']
                .map<DropdownMenuItem<String>>(
                  (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              },
            ).toList(),
            hint: Text('Program'),
          ),
          SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedProgramTerm,
            onChanged: (String? value) {
              setState(() {
                _selectedProgramTerm = value!;
              });
            },
            items: _selectedProgram.isEmpty || _selectedProgram == '--Program--'
                ? []
                : ['--Program Term--', 'FY', 'SY', 'TY']
                .map<DropdownMenuItem<String>>(
                  (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              },
            ).toList(),
            hint: Text('Program Term'),
          ),
          SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedClass,
            onChanged: (String? value) {
              setState(() {
                _selectedClass = value!;
              });
            },
            items: ['--Division--', 'A', 'B', 'C']
                .map<DropdownMenuItem<String>>(
                  (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              },
            ).toList(),
            hint: Text('Class'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('students').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<DocumentSnapshot> students = snapshot.data!.docs;

        // Filter students based on selected program
        if (_selectedProgram.isNotEmpty) {
          students = students.where((student) {
            return student['Program'] == _selectedProgram;
          }).toList();
        }

        // Filter students based on selected program term
        if (_selectedProgramTerm.isNotEmpty) {
          students = students.where((student) {
            return student['Program Term'] == _selectedProgramTerm;
          }).toList();
        }

        // Filter students based on selected class
        if (_selectedClass.isNotEmpty) {
          students = students.where((student) {
            return student['Division'] == _selectedClass;
          }).toList();
        }

        // Filter students based on search query
        if (_searchController.text.isNotEmpty) {
          final searchQuery = _searchController.text.toLowerCase();
          students = students.where((student) {
            return student['First Name'].toLowerCase().contains(searchQuery);
          }).toList();
        }

        if (students.isEmpty) {
          return Center(
            child: Text('No data found'),
          );
        }

        return DataTable(
          columns: [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Program')),
            DataColumn(label: Text('Program Term')),
            DataColumn(label: Text('Class')),
          ],
          rows: students.map((student) {
            return DataRow(cells: [
              DataCell(Text(student['First Name'])),
              DataCell(Text(student['Program'])),
              DataCell(Text(student['Program Term'])),
              DataCell(Text(student['Division'])),
            ]);
          }).toList(),
        );
      },
    );
  }
}



//
// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// class UploadImageAndMore extends StatefulWidget {
//   const UploadImageAndMore({super.key});
//
//   @override
//   State<UploadImageAndMore> createState() => _UploadImageAndMoreState();
// }
//
// class _UploadImageAndMoreState extends State<UploadImageAndMore> {
//   // text fiedl controller
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _numberController = TextEditingController();
//
//   final CollectionReference _items =
//   FirebaseFirestore.instance.collection("Upload_Items");
//   // collection name must be same as firebase collection name
//
//   String imageUrl = '';
//
//   Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
//     await showModalBottomSheet(
//         isScrollControlled: true,
//         context: context,
//         builder: (BuildContext ctx) {
//           return Padding(
//             padding: EdgeInsets.only(
//                 top: 20,
//                 right: 20,
//                 left: 20,
//                 bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Center(
//                   child: Text("Create your Items"),
//                 ),
//                 TextField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(
//                       labelText: 'Name', hintText: 'eg Elon'),
//                 ),
//                 TextField(
//                   controller: _numberController,
//                   decoration: const InputDecoration(
//                       labelText: 'Number', hintText: 'eg 10'),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Center(
//                     child: IconButton(
//                         onPressed: () async {
//                           // add the package image_picker
//                           final file = await ImagePicker()
//                               .pickImage(source: ImageSource.gallery);
//                           if (file == null) return;
//
//                           String fileName =
//                           DateTime.now().microsecondsSinceEpoch.toString();
//
//                           // Get the reference to storage root
//                           // We create the image folder first and insider folder we upload the image
//                           Reference referenceRoot =
//                           FirebaseStorage.instance.ref();
//                           Reference referenceDireImages =
//                           referenceRoot.child('Profiles');
//
//                           // we have creata reference for the image to be stored
//                           Reference referenceImageaToUpload =
//                           referenceDireImages.child(fileName);
//
//                           // For errors handled and/or success
//                           try {
//                             await referenceImageaToUpload
//                                 .putFile(File(file.path));
//
//                             // We have successfully upload the image now
//                             // make this upload image link in firebase database
//
//                             imageUrl =
//                             await referenceImageaToUpload.getDownloadURL();
//                           } catch (error) {
//                             //some error
//                           }
//                         },
//                         icon: const Icon(Icons.camera_alt))),
//                 Center(
//                     child: ElevatedButton(
//                         onPressed: () async {
//                           if (imageUrl.isEmpty) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                     content: Text(
//                                         "Please select and upload image")));
//                             return;
//                           }
//                           final String name = _nameController.text;
//                           final int? number =
//                           int.tryParse(_numberController.text);
//                           if (number != null) {
//                             await _items.add({
//                               // Add items in you firebase firestore
//                               "name": name,
//                               "number": number,
//                               "image": imageUrl,
//                             });
//                             _nameController.text = '';
//                             _numberController.text = '';
//                             Navigator.of(context).pop();
//                           }
//                         },
//                         child: const Text('Create')))
//               ],
//             ),
//           );
//         });
//   }
//
//   late Stream<QuerySnapshot> _stream;
//   @override
//   void initState() {
//     super.initState();
//     _stream = FirebaseFirestore.instance.collection('Upload_Items').snapshots();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Upload and display Items"),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//           stream: _stream,
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
//             if (snapshot.hasError) {
//               return Center(
//                 child: Text("Some error occured${snapshot.error}"),
//               );
//             }
//             // Now , Cheeck if datea arrived?
//             if (snapshot.hasData) {
//               QuerySnapshot querySnapshot = snapshot.data;
//               List<QueryDocumentSnapshot> document = querySnapshot.docs;
//
//               // We need to Convert your documnets to Maps to display
//               List<Map> items = document.map((e) => e.data() as Map).toList();
//
//               //At Last, Display the list of items
//               return ListView.builder(
//                   itemCount: items.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     Map thisItems = items[index];
//                     return ListTile(
//                         title: Text(
//                           "${thisItems['name']}",
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 17),
//                         ),
//                         subtitle: Text("${thisItems['number']}"),
//                         leading: CircleAvatar(
//                           radius: 27,
//                           child: thisItems.containsKey('image')
//                               ? ClipOval(
//                             child: Image.network(
//                               "${thisItems['image']}",
//                               fit: BoxFit.cover,
//                               height: 70,
//                               width: 70,
//                             ),
//                           )
//                               : const CircleAvatar(),
//                         ));
//                   });
//             }
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _create();
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
