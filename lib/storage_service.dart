import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  Future<void> uplaodFile(String fileName,var filePath) async {
    try {
      await firebaseStorage.ref('Profiles/$fileName').putData(filePath).then((p0) async {
        log("Uploaded");
        String imgurl=await firebaseStorage.ref('Profiles/$fileName').getDownloadURL();
        print(imgurl);
      });
    } catch (e) {
      log("Error: $e");
    }
  }

  Future<ListResult> listFiles() async {
    ListResult listResults = await firebaseStorage.ref('Profiles').listAll();
    return listResults;
  }
}