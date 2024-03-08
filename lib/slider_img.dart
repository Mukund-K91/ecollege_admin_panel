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

  });
}
class SliderPage extends StatefulWidget {
  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  String imageUrl = '';
  DateTime? startDate;
  DateTime? endDate;

  Future<void> uploadImage() async {
    final result = await ImagePickerWeb.getImageInfo;
    if (result != null) {
      final imageBytes = result.data!;
      final name = result.fileName;
      final ref = firebase_storage.FirebaseStorage.instance.ref().child('slider_images').child(name!);
      await ref.putData(imageBytes);
      imageUrl = await ref.getDownloadURL();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Slider Page'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: uploadImage,
                child: Text('Upload Image'),
              ),
              SizedBox(height: 20),
              if (imageUrl.isNotEmpty) Image.network(imageUrl),
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
                onPressed: () {
                  // Save the image URL, start date, and end date to Firestore
                  // Add your Firestore save logic here
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _addImgToSlider(){

}
}
