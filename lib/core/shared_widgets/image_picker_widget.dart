import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/lang_keys.dart';
import '../constants/ui_constants.dart';
import '../services/storage_service.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(dynamic imageData) onImageSelected;
  final String? initialImageUrl;

  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.initialImageUrl,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final TextEditingController _urlController = TextEditingController();
  dynamic _imagePreview;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialImageUrl != null) {
      _imagePreview = widget.initialImageUrl;
      _urlController.text = widget.initialImageUrl!;
    }
  }
  Future<void> _pickImage() async {
    setState(() { _isLoading = true; });
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imagePreview = imageBytes;
        _urlController.clear();
      });
      widget.onImageSelected(imageBytes);
    }
    setState(() { _isLoading = false; });
  }

  void _useUrl() {
    final url = _urlController.text.trim();
    if (GetUtils.isURL(url)) {
      setState(() {
        _imagePreview = url;
      });
      widget.onImageSelected(url);
    } else {
      Get.snackbar(LangKeys.error.tr, LangKeys.invalidUrl.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.circular(kDefaultRadius),
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _imagePreview != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(kDefaultRadius),
            child: _imagePreview is String
                ? Image.network(_imagePreview as String, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: kErrorColor))
                : Image.memory(_imagePreview as Uint8List, fit: BoxFit.cover),
          )
              : const Center(child: Icon(Icons.image, size: 50, color: kSecondaryTextColor)),
        ),
        const SizedBox(height: kDefaultPadding),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file),
                label: Text(LangKeys.uploadImage.tr),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Center(child: Text(LangKeys.orEnterUrl.tr)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _urlController,
          decoration: InputDecoration(
            labelText: LangKeys.imageUrl.tr,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: _useUrl,
            ),
          ),
        ),
      ],
    );
  }
}