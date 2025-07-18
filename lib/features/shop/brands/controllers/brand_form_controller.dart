import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/services/storage/storage_service_interface.dart';
import '../../../../core/shared_widgets/image_uploader_widget.dart';
import '../../../../core/shared_widgets/loading_overlay.dart'
    show LoadingOverlay;
import '../../../../core/utils/validators.dart';
import '../../models/brand_model.dart';

class BrandFormController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final IStorageService _storageService = Get.find<IStorageService>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Form field controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final urlController = TextEditingController(); // Manages the URL text field

  // State management
  final Rxn<ImageSourceData> selectedImageFile = Rxn<ImageSourceData>();
  Rx<BrandModel?> brandToEdit = Rx<BrandModel?>(null);

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is BrandModel) {
      brandToEdit.value = Get.arguments;
      _loadBrandData(brandToEdit.value!);
    }
  }

  void _loadBrandData(BrandModel brand) {
    nameController.text = brand.name;
    descriptionController.text = brand.description ?? '';
    if (brand.logoUrl.isNotEmpty) {
      urlController.text = brand.logoUrl;
    }
  }

  // Called when a user selects a file from their device
  void onFileSelected(ImageSourceData? data) {
    selectedImageFile.value = data;
    if (data != null) {
      urlController.clear();
    }
  }

  Future<void> saveBrand() async {
    if (!formKey.currentState!.validate()) return;

    LoadingOverlay.show(message: LangKeys.savingBrand.tr);
    try {
      String finalLogoUrl = brandToEdit.value?.logoUrl ?? '';
      final imageFile = selectedImageFile.value;
      final manualUrl = urlController.text.trim();

      if (imageFile != null && imageFile.data is Uint8List) {
        // Priority 1: A new image file was uploaded.
        final imageData = imageFile.data as Uint8List;
        String? uploadedUrl = await _storageService.uploadImage(
          path: 'brands/',
          imageData: imageData,
          fileName: 'brand_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        if (uploadedUrl == null) throw Exception(LangKeys.imageUploadFailed.tr);
        finalLogoUrl = uploadedUrl;
      } else if (manualUrl.isNotEmpty && Validators.isValidUrl(manualUrl)) {
        // Priority 2: No file, but a valid URL was entered.
        finalLogoUrl = manualUrl;
      } else if (manualUrl.isEmpty && imageFile == null) {
        // Priority 3: Both fields are empty, so clear the logo.
        finalLogoUrl = '';
      }

      final brandData = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'logoUrl': finalLogoUrl,
      };

      if (brandToEdit.value != null) {
        await _firestore
            .collection('brands')
            .doc(brandToEdit.value!.id)
            .update(brandData);
      } else {
        await _firestore.collection('brands').add(brandData);
      }

      LoadingOverlay.hide();
      Get.back(result: true);
      Get.snackbar(
        LangKeys.success.tr,
        brandToEdit.value != null
            ? LangKeys.brandUpdatedSuccess.tr
            : LangKeys.brandAddedSuccess.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kAccentColor,
        colorText: Colors.white,
      );
    } catch (e) {
      LoadingOverlay.hide();
      Get.snackbar(
        LangKeys.error.tr,
        '${LangKeys.failedToSaveBrand.tr}: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kErrorColor,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    urlController.dispose();
    super.onClose();
  }
}
