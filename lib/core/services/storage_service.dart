import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class StorageService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImageData(String path, Uint8List imageData) async {
    try {
      final ref = _storage
          .ref(path)
          .child('${DateTime.now().toIso8601String()}.jpg');
      final uploadTask = await ref.putData(imageData);
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      Get.snackbar('Error', 'Image upload failed: $e');
      return null;
    }
  }
}
