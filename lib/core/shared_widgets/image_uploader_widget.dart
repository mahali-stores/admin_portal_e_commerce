import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/lang_keys.dart';
import '../constants/ui_constants.dart';

class ImageSourceData {
  final dynamic data; // Can be Uint8List (new file) or String (URL)
  ImageSourceData(this.data);
}

class ImageUploaderWidget extends StatefulWidget {
  // This widget now takes the URL controller directly from the parent
  // to ensure state synchronization.
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
  // The widget now only manages the state of a selected FILE.
  // The URL state is managed by the controller passed into the widget.
  ImageSourceData? _selectedFile;
  bool _isLoading = false;
  String? _previewImageUrl;

  @override
  void initState() {
    super.initState();
    // Set the initial preview from the initial URL
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

  void _updatePreviewFromUrl() {
    final url = widget.urlController.text.trim();
    if (url.isNotEmpty && GetUtils.isURL(url)) {
      // If a valid URL is typed, update the preview and clear any selected file.
      setState(() {
        _previewImageUrl = url;
        _selectedFile = null;
      });
      widget.onFileSelected(null);
    }
  }

  Future<void> _pickImage() async {
    setState(() { _isLoading = true; });
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null) {
        final imageBytes = await pickedFile.readAsBytes();
        final newFileSource = ImageSourceData(imageBytes);
        setState(() {
          _selectedFile = newFileSource;
          _previewImageUrl = null; // A file is picked, so the URL preview is irrelevant
        });
        // Notify the parent controller of the new file and clear the URL field
        widget.onFileSelected(newFileSource);
        widget.urlController.clear();
      }
    } catch (e) {
      Get.snackbar(LangKeys.error.tr, "Failed to pick image: $e");
    } finally {
      setState(() { _isLoading = false; });
    }
  }

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
    // Determine what to show in the preview area
    Widget previewContent;
    if (_isLoading) {
      previewContent = const Center(child: CircularProgressIndicator());
    } else if (_selectedFile != null) {
      previewContent = _buildImagePreview(_selectedFile!.data as Uint8List);
    } else if (_previewImageUrl != null && _previewImageUrl!.isNotEmpty) {
      previewContent = _buildImagePreview(_previewImageUrl as String);
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

  Widget _buildImagePreview(dynamic imageData) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(kDefaultRadius),
          child: imageData is String
              ? Image.network(imageData, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildErrorState())
              : Image.memory(imageData as Uint8List, fit: BoxFit.cover),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kDefaultRadius),
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                style: IconButton.styleFrom(backgroundColor: kErrorColor.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(kDefaultRadius),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload_outlined, size: 50, color: kSecondaryTextColor),
                const SizedBox(height: kDefaultPadding),
                Text(LangKeys.uploadImage.tr, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: kDefaultPadding / 2),
                Text(
                  LangKeys.uploadInstructions.tr,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrlInputField() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(LangKeys.orEnterUrl.tr, style: Theme.of(context).textTheme.bodyMedium),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: kDefaultPadding),
        TextFormField(
          controller: widget.urlController,
          decoration: InputDecoration(
            labelText: LangKeys.imageUrl.tr,
            hintText: 'https://...',
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

  Widget _buildErrorState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(kDefaultRadius),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: kErrorColor, size: 40),
            SizedBox(height: 8),
            Text("Could not load image", style: TextStyle(color: kErrorColor)),
          ],
        ),
      ),
    );
  }
}
