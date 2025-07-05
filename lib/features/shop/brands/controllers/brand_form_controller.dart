import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/services/storage_service.dart';
import '../../models/brand_model.dart';

class BrandFormController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = Get.find<StorageService>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  final RxBool isLoading = false.obs;
  // --- UPDATED: Holds either a String (URL) or Uint8List (new image data) ---
  final Rx<dynamic> selectedImageData = Rx<dynamic>(null);
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
    // Load the existing image URL as a String
    selectedImageData.value = brand.logoUrl;
  }

  // The ImagePickerWidget now provides dynamic data
  void onImageSelected(dynamic data) {
    selectedImageData.value = data;
  }

  Future<void> saveBrand() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    try {
      String logoUrl = '';

      // --- REFACTORED: Universal image handling logic ---
      if (selectedImageData.value is String) {
        // It's an existing URL, so just use it.
        logoUrl = selectedImageData.value;
      } else if (selectedImageData.value is Uint8List) {
        // It's new image data, so upload it.
        String? uploadedUrl = await _storageService.uploadImageData('brands/', selectedImageData.value);
        if (uploadedUrl == null) {
          isLoading.value = false;
          return; // Upload failed
        }
        logoUrl = uploadedUrl;
      }

      final brandData = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'logoUrl': logoUrl,
      };

      if (brandToEdit.value != null) {
        // Update existing brand
        await _firestore.collection('brands').doc(brandToEdit.value!.id).update(brandData);
      } else {
        // Add new brand
        await _firestore.collection('brands').add(brandData);
      }

      Get.back(result: true); // Go back and signal success
      Get.snackbar(
        'Success',
        brandToEdit.value != null ? 'Brand updated successfully' : 'Brand added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save brand: $e');
    } finally {
      isLoading.value = false;
    }
  }
}