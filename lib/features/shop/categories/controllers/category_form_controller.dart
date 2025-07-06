import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/services/storage/storage_service_interface.dart';
import '../../../../core/shared_widgets/image_uploader_widget.dart';
import '../../../../core/shared_widgets/loading_overlay.dart';
import '../../../../core/utils/validators.dart';
import '../../models/category_model.dart';

class CategoryFormController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final IStorageService _storageService = Get.find<IStorageService>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Form field controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final urlController = TextEditingController(); // Manages the URL text field directly

  // State management
  final Rxn<ImageSourceData> selectedImageFile = Rxn<ImageSourceData>(); // Only for file uploads
  final Rxn<String> parentCategoryId = Rxn<String>();
  final RxList<CategoryModel> availableParentCategories = <CategoryModel>[].obs;
  Rx<CategoryModel?> categoryToEdit = Rx<CategoryModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchParentCategories();
    if (Get.arguments is CategoryModel) {
      categoryToEdit.value = Get.arguments;
      _loadCategoryData(categoryToEdit.value!);
    }
  }

  Future<void> fetchParentCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').orderBy('name').get();
      final categories = snapshot.docs.map((doc) => CategoryModel.fromSnapshot(doc)).toList();
      if (categoryToEdit.value != null) {
        categories.removeWhere((cat) => cat.id == categoryToEdit.value!.id);
      }
      availableParentCategories.assignAll(categories);
    } catch (e) {
      Get.snackbar('Error', 'Could not fetch parent categories: $e');
    }
  }

  void _loadCategoryData(CategoryModel category) {
    nameController.text = category.name.replaceAll('— ', '');
    descriptionController.text = category.description ?? '';
    if (category.imageUrl != null && category.imageUrl!.isNotEmpty) {
      selectedImageFile.value = ImageSourceData(category.imageUrl);
      urlController.text = category.imageUrl!;
    }
    parentCategoryId.value = category.parentCategoryId;
  }

  void onFileSelected(ImageSourceData? data) {
    selectedImageFile.value = data;
    if (data != null) {
      urlController.clear();
    }
  }

  void onParentCategoryChanged(String? newId) {
    parentCategoryId.value = newId;
  }

  Future<void> saveCategory() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    LoadingOverlay.show(message: "Saving category...");
    try {
      String finalImageUrl = '';
      final imageFile = selectedImageFile.value;
      final manualUrl = urlController.text.trim();

      if (imageFile != null && imageFile.data is Uint8List) {
        // Priority 1: An image file has been uploaded.
        final imageData = imageFile.data as Uint8List;
        String? uploadedUrl = await _storageService.uploadImage(
            path: 'categories/',
            imageData: imageData,
            fileName: 'category_${DateTime.now().millisecondsSinceEpoch}.jpg'
        ).timeout(const Duration(seconds: 30));

        if (uploadedUrl == null) throw Exception("Image upload failed or timed out.");
        finalImageUrl = uploadedUrl;

      } else if (manualUrl.isNotEmpty && Validators.isValidUrl(manualUrl)) {
        // Priority 2: No file, but a valid URL has been entered manually.
        finalImageUrl = manualUrl;
      }

      final categoryData = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'imageUrl': finalImageUrl,
        'parentCategoryId': parentCategoryId.value,
      };

      if (categoryToEdit.value != null) {
        await _firestore.collection('categories').doc(categoryToEdit.value!.id).update(categoryData);
      } else {
        await _firestore.collection('categories').add(categoryData);
      }

      LoadingOverlay.hide();
      Get.back(result: true);
      Get.snackbar(
          'Success',
          categoryToEdit.value != null ? 'Category updated' : 'Category added',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kAccentColor,
          colorText: Colors.white
      );
    } catch (e) {
      LoadingOverlay.hide();
      Get.snackbar('Error', 'Failed to save category: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kErrorColor,
          colorText: Colors.white);
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
