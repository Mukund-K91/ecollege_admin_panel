import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecollege_admin_panel/reusable_widget/reusable_textfield.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';

class appSlider {
  final String id;
  final String ImgUrl;
  final DateTime publisdate;
  final DateTime deletedate;

  appSlider(
      {required this.id,
      required this.ImgUrl,
      required this.publisdate,
      required this.deletedate});
}

final _filenameController = TextEditingController();
final TextEditingController _dobController = TextEditingController();
DateTime? _selectedDate;



class SliderPage extends StatefulWidget {
  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  String? imageUrl;
  DateTime? startDate;
  DateTime? endDate;

  Future<void> uploadImage() async {
    final result = await ImagePickerWeb.getImageInfo;
    if (result != null) {
      final imageBytes = result.data!;
      final name = result.fileName!;
      setState(() {
        _filenameController.text=name;
      });
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('slider_images')
          .child(name);
      await ref.putData(imageBytes);
      imageUrl = await ref.getDownloadURL();
    }
  }
  void saveSliderData() {
    if (imageUrl != null && startDate != null && endDate != null) {
      FirebaseFirestore.instance.collection('slider_data').add({
        'imageUrl': imageUrl,
        'startDate': startDate,
        'endDate': endDate,
      }).then((value) {
        // Data saved successfully
        print('Data saved to Firestore');
      }).catchError((error) {
        // Handle errors
        print('Failed to save data: $error');
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd-MM-yyyy').format(_selectedDate!);
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
            children: [_addImgToSlider()],
          ),
        ));
  }

  Widget _addImgToSlider() {
    return Row(
      children: [
        Expanded(
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
                        minimumSize: const Size(100, 50),
                        backgroundColor: const Color(0xff002233),
                        shape: const ContinuousRectangleBorder()),
                    onPressed: uploadImage,
                    child: const Text(
                      "Upload",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    )),
              ),
            ),
          ],
        )
        ),
        Expanded(
            flex: 1,
            child: ReusableTextField(
              readOnly: true,
              controller: _dobController,
              OnTap: () => _selectDate(context),
              title: 'DOB',
            )),
      ],
    );
  }
}
