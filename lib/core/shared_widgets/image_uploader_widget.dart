import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/lang_keys.dart';
import '../constants/ui_constants.dart';

// Data class to hold either a file (Uint8List) or a URL (String)
class ImageSourceData {
  final dynamic data;
  ImageSourceData(this.data);
}

class ImageUploaderWidget extends StatefulWidget {
  final TextEditingController urlController;
  final Function(ImageSourceData?) onFileSelected;
  final String? initialImageUrl;

  const ImageUploaderWidget({
    super.key,
    required this.urlController,
    required this.onFileSelected,
    this.initialImageUrl,
  });

  @override
  State<ImageUploaderWidget> createState() => _ImageUploaderWidgetState();
}

class _ImageUploaderWidgetState extends State<ImageUploaderWidget> {
  ImageSourceData? _selectedFile;
  bool _isLoading = false;
  String? _previewImageUrl;

  @override
  void initState() {
    super.initState();
    // Set the initial preview from the initial URL if available
    if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
      _previewImageUrl = widget.initialImageUrl;
    }
    // Listen to the URL controller to update the preview in real-time
    widget.urlController.addListener(_updatePreviewFromUrl);
  }

  @override
  void dispose() {
    widget.urlController.removeListener(_updatePreviewFromUrl);
    super.dispose();
  }

  // Updates the preview when the user types a URL
  void _updatePreviewFromUrl() {
    final url = widget.urlController.text.trim();
    if (url.isNotEmpty && GetUtils.isURL(url)) {
      // If a valid URL is typed, update the preview and clear any selected file.
      if (mounted) {
        setState(() {
          _previewImageUrl = url;
          if (_selectedFile != null) {
            _selectedFile = null;
            widget.onFileSelected(null);
          }
        });
      }
    }
  }

  // Picks an image from the gallery
  Future<void> _pickImage() async {
    setState(() => _isLoading = true);
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null) {
        final imageBytes = await pickedFile.readAsBytes();
        final newFileSource = ImageSourceData(imageBytes);
        setState(() {
          _selectedFile = newFileSource;
          _previewImageUrl = null;
        });
        widget.onFileSelected(newFileSource);
        widget.urlController.clear();
      }
    } catch (e) {
      Get.snackbar(LangKeys.error.tr, "${LangKeys.failedToPickImage.tr}: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Removes the current image (file or URL)
  void _removeImage() {
    setState(() {
      _selectedFile = null;
      _previewImageUrl = null;
    });
    widget.onFileSelected(null);
    widget.urlController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent;
    if (_isLoading) {
      previewContent = const Center(child: CircularProgressIndicator());
    } else if (_selectedFile != null) {
      previewContent = _buildImagePreview(_selectedFile!.data as Uint8List);
    } else if (_previewImageUrl != null && _previewImageUrl!.isNotEmpty) {
      previewContent = _buildImagePreview(_previewImageUrl!);
    } else {
      previewContent = _buildImagePicker();
    }

    return Column(
      children: [
        SizedBox(height: 200, width: double.infinity, child: previewContent),
        const SizedBox(height: kDefaultPadding),
        _buildUrlInputField(),
      ],
    );
  }

  // Widget to display when an image is selected or a URL is provided
  Widget _buildImagePreview(dynamic imageData) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kDefaultRadius),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kDefaultRadius),
            child: imageData is String
                ? Image.network(imageData, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _buildErrorState())
                : Image.memory(imageData as Uint8List, fit: BoxFit.cover),
          ),
        ),
        // Overlay with action buttons
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(kDefaultRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(LangKeys.changeImage.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: kTextColor,
                  ),
                ),
                const SizedBox(width: kDefaultPadding / 2),
                IconButton(
                  onPressed: _removeImage,
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  tooltip: LangKeys.removeImage.tr,
                  style: IconButton.styleFrom(
                      backgroundColor: kErrorColor.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget to display when no image is selected
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(kDefaultRadius),
        color: kSecondaryTextColor,
        strokeWidth: 1.5,
        dashPattern: const [6, 6],
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(kDefaultRadius),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload_outlined,
                    size: 50, color: kSecondaryTextColor),
                const SizedBox(height: kDefaultPadding),
                Text(LangKeys.uploadImage.tr, style: Get.textTheme.titleMedium),
                const SizedBox(height: kDefaultPadding / 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  child: Text(
                    LangKeys.uploadInstructions.tr,
                    style: Get.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // The URL input field section
  Widget _buildUrlInputField() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(LangKeys.orEnterUrl.tr, style: Get.textTheme.bodyMedium),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: kDefaultPadding),
        TextFormField(
          controller: widget.urlController,
          decoration: InputDecoration(
            labelText: LangKeys.imageUrl.tr,
            hintText: LangKeys.imageUrlHint.tr,
            prefixIcon: const Icon(Icons.link),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty && !GetUtils.isURL(value)) {
              return LangKeys.invalidUrl.tr;
            }
            return null;
          },
        ),
      ],
    );
  }

  // Widget to display in case of a network image error
  Widget _buildErrorState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(kDefaultRadius),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: kErrorColor, size: 40),
            const SizedBox(height: 8),
            Text(LangKeys.couldNotLoadImage.tr,
                style: const TextStyle(color: kErrorColor)),
          ],
        ),
      ),
    );
  }
}
