import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker_web/image_picker_web.dart';

class appSlider {
  final String id;
  final String ImgUrl;
  final DateTime publisdate;
  final DateTime deletedate;

  appSlider({
    required this.id,
    required this.ImgUrl,
    required this.publisdate,
    required this.deletedate

  });
}

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
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('slider_images')
          .child(name);
      await ref.putData(imageBytes);
      imageUrl = await ref.getDownloadURL();
      setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Slider Page'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: uploadImage,
              child: Text('Upload Image'),
            ),
            SizedBox(height: 20),
            if (imageUrl != null) Image.network(imageUrl!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final selectedStartDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (selectedStartDate != null) {
                  setState(() {
                    startDate = selectedStartDate;
                  });
                }
              },
              child: Text('Select Start Date'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final selectedEndDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (selectedEndDate != null) {
                  setState(() {
                    endDate = selectedEndDate;
                  });
                }
              },
              child: Text('Select End Date'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveSliderData,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

