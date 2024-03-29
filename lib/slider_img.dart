import 'dart:html';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecollege_admin_panel/reusable_widget/reusable_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';

class appSlider {
  final String id;
  final String ImgUrl;
  final DateTime publisdate;
  final DateTime deletedate;

  appSlider({required this.id,
    required this.ImgUrl,
    required this.publisdate,
    required this.deletedate});
}

final DateTime _date = DateTime.now();

final _filenameController = TextEditingController();
late TextEditingController _endDateController =
TextEditingController(text: "DD-MM-YYYY");
DateTime? _selectedDate;

class SliderPage extends StatefulWidget {
  @override
  _SliderPageState createState() => _SliderPageState();
}

final CollectionReference _sliderDataCol =
FirebaseFirestore.instance.collection('slider_data');

class _SliderPageState extends State<SliderPage> {
  String? imageUrl;
  DateTime? endDate;

  Future<void> uploadImage() async {
    final result = await ImagePickerWeb.getImageInfo;
    if (result != null) {
      final imageBytes = result.data!;
      final name = result.fileName!;
      setState(() {
        _filenameController.text = name;
      });
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('slider_images')
          .child(name);
      await ref.putData(imageBytes);
      imageUrl = await ref.getDownloadURL();
    }
  }

  final _publishdate = DateFormat('dd-MM-yyyy').format(_date);
  List<Map<String, dynamic>> sliderData = [];

  void saveSliderData() {
    if (imageUrl != null && endDate != null) {
      FirebaseFirestore.instance.collection('slider_data').add({
        'imageUrl': imageUrl,
        'startDate': _date,
        'endDate': endDate,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.white,
              shape: ContinuousRectangleBorder(),
              content: Text(
                'Added',
                style: TextStyle(color: Colors.black),
              )),
        );
        // Data saved successfully
        print('Data saved to Firestore');
      }).catchError((error) {
        // Handle errors
        print('Failed to save data: $error');
      });
    }
    _filenameController.clear();
    _endDateController.clear();
    setState(() {});
  }

  Future<void> fetchSliderData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('slider_data')
        .orderBy('startDate')
        .orderBy('endDate', descending: true) // Order by end date in descending order
        .get();

    final List<Map<String, dynamic>> data = [];

    querySnapshot.docs.forEach((doc) {
      final Map<String, dynamic> slider = {
        'imageUrl': doc['imageUrl'],
        'endDate': (doc['endDate'] as Timestamp).toDate(),
      };
      data.add(slider);
    });

    setState(() {
      sliderData = data;
    });
  }


  void initState() {
    super.initState();
    _endDateController = TextEditingController();
    fetchSliderData();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        endDate = _selectedDate;
        _endDateController.text =
            DateFormat('dd-MM-yyyy').format(_selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Manage Sliders',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                    color: Colors.grey.shade100,
                    child: _addImgToSlider(context)),
              ),
              _SliderList()
            ],
          ),
        ));
  }

  Padding _addImgToSlider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      ReusableTextField(
                        readOnly: true,
                        controller: _filenameController,
                        title: 'Image',
                        sufIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(150, 50),
                                  backgroundColor: const Color(0xff002233),
                                  shape: const ContinuousRectangleBorder()),
                              onPressed: uploadImage,
                              child: const Text(
                                "Upload",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              )),
                        ),
                      ),
                    ],
                  )),
              SizedBox(
                width: 20,
              ),
              Expanded(
                  child: ReusableTextField(
                    readOnly: true,
                    controller: _endDateController,
                    OnTap: () => _selectDate(context),
                    title: 'End Date',
                  )),
              SizedBox(
                width: 20,
              ),
              Expanded(
                  child: RichText(
                      text: TextSpan(
                          text: "Timeline\n\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                                text: "${_publishdate} TO ${_endDateController
                                    .text}")
                          ]))),
              SizedBox(
                width: 20,
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  maximumSize: const Size(180, 65),
                  minimumSize: const Size(180, 65),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  backgroundColor: const Color(0xff002233),
                ),
                onPressed: saveSliderData,
                child: const Text(
                  "Add",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )),
          ),
        ],
      ),
    );
  }

  Widget _SliderList() {

    return
      StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('slider_data').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Or any other loading indicator
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No data available'); // Or any other placeholder widget
        }

        return Container(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: DataTable(
              border: TableBorder.all(color: Colors.black),
              columns: [
                DataColumn(label: Text('Image')),
                DataColumn(label: Text('Created At')),
                DataColumn(label: Text('End Date')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Action')),
              ],
              dataRowMaxHeight: double.infinity,
              rows: snapshot.data!.docs.map((doc) {
                final imageUrl = doc['imageUrl'] ?? '';
                final startDate = doc['startDate'] != null
                    ? DateFormat('dd-MM-yyyy hh:mm a')
                    .format((doc['startDate'] as Timestamp).toDate())
                    : '';
                final Timestamp? endDateTimestamp =
                doc['endDate'] as Timestamp?;
                final DateTime? endDate =
                endDateTimestamp != null ? endDateTimestamp.toDate() : null;
                final String endDateFormatted = endDate != null
                    ? DateFormat('dd-MM-yyyy').format(endDate)
                    : '';
                final bool isActive =
                endDate != null ? DateTime.now().isBefore(endDate) : false;

                return DataRow(cells: [
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        width: 130,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          fit: BoxFit
                              .cover, // Adjust the fit as per your requirement
                        )
                            : Placeholder(
                          child: Text("NO found"),
                        ), // Placeholder if imageUrl is empty
                      ),
                    ),
                  ),
                  DataCell(Text(startDate)),
                  DataCell(Text("${endDateFormatted}")),
                  DataCell(Text(isActive ? "Active" : "Closed",
                    style: TextStyle(
                        color: isActive ? Colors.green : Colors.redAccent),)),
                  DataCell(IconButton(
                      onPressed: () => _deleteImg(doc.id,imageUrl),
                      icon: Icon(
                        FontAwesomeIcons.trash,
                        color: Colors.redAccent,
                      )))
                ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _deleteImg(String id, String imageUrl) {
    AwesomeDialog(
      width: 400,
      context: context,
      dialogType: DialogType.question,
      btnOkOnPress: () async {
        // Delete document from Firestore
        await _sliderDataCol.doc(id).delete();

        // Delete image from Firebase Storage
        if (imageUrl.isNotEmpty) {
          try {
            await firebase_storage.FirebaseStorage.instance.refFromURL(imageUrl).delete();
            // Image deleted successfully
            print('Image deleted from Firebase Storage');
          } catch (error) {
            // Error handling for image deletion
            print('Failed to delete image: $error');
          }
        }

        // Show snackbar
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Deleted")));
      },
      showCloseIcon: true,
      title: "Are You Sure?",
    ).show();
  }
}
