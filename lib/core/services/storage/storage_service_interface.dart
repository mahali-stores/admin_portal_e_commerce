import 'dart:typed_data';

abstract class IStorageService {
  Future<String?> uploadImage({
    required String path,
    required Uint8List imageData,
    required String fileName,
  });
}