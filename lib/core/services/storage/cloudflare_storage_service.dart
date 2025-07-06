
import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../constants/lang_keys.dart';
import 'storage_service_interface.dart';

class CloudflareStorageService extends GetxService implements IStorageService {
  final String _uploadUrl = "https://ecommerce-image-uploader.mahali-e-stores.workers.dev/";
  final String _apiKey = "QyQuBzZZCVMiMoWDD0VcDFAjaj94Qti3";

  @override
  Future<String?> uploadImage({
    required String path,
    required Uint8List imageData,
    required String fileName,
  }) async {
    try {
      final uri = Uri.parse(_uploadUrl);
      final request = http.MultipartRequest('POST', uri);

      // Add headers, including your API key for authentication.
      request.headers['Authorization'] = 'Bearer $_apiKey';

      // Add the destination path as a field
      request.fields['path'] = path;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageData,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        final imageUrl = jsonResponse['url'];
        if (imageUrl != null) {
          return imageUrl;
        } else {
          Get.snackbar(LangKeys.error.tr, 'Upload succeeded but no URL was returned.');
          return null;
        }
      } else {
        final errorBody = await response.stream.bytesToString();
        print("Cloudflare Upload Error: ${response.statusCode} - $errorBody");
        Get.snackbar(LangKeys.error.tr, '${LangKeys.imageUploadFailed.tr}: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print("Cloudflare Upload Exception: $e");
      Get.snackbar(LangKeys.error.tr, '${LangKeys.imageUploadFailed.tr}: $e');
      return null;
    }
  }
}