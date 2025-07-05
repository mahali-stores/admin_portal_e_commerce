import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/services/storage_service.dart';
import '../../models/category_model.dart';

class CategoryFormController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = Get.find<StorageService>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  final RxBool isLoading = false.obs;
  // --- UPDATED: Holds either a String (URL) or Uint8List (new image data) ---
  final Rx<dynamic> selectedImageData = Rx<dynamic>(null);
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

  // ... fetchParentCategories() remains the same ...
  Future<void> fetchParentCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
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
    nameController.text = category.name;
    descriptionController.text = category.description ?? '';
    selectedImageData.value = category.imageUrl;
    parentCategoryId.value = category.parentCategoryId;
  }

  void onImageSelected(dynamic data) {
    selectedImageData.value = data;
  }

  void onParentCategoryChanged(String? newId) {
    parentCategoryId.value = newId;
  }

  Future<void> saveCategory() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    try {
      String imageUrl = '';

      // --- ADDED TIMEOUT TO IMAGE UPLOAD ---
      if (selectedImageData.value is Uint8List) {
        // If upload takes more than 20 seconds, it will throw an error.
        String? uploadedUrl = await _storageService
            .uploadImageData('categories/', selectedImageData.value)
            .timeout(const Duration(seconds: 20));

        if (uploadedUrl == null) {
          throw('Image upload returned null.'); // Manually throw error to be caught
        }
        imageUrl = uploadedUrl;
      } else if (selectedImageData.value is String) {
        imageUrl = selectedImageData.value;
      }

      final categoryData = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'imageUrl': imageUrl,
        'parentCategoryId': parentCategoryId.value,
      };

      // --- ADDED TIMEOUT TO FIRESTORE WRITE ---
      if (categoryToEdit.value != null) {
        await _firestore
            .collection('categories')
            .doc(categoryToEdit.value!.id)
            .update(categoryData)
            .timeout(const Duration(seconds: 15));
      } else {
        await _firestore
            .collection('categories')
            .add(categoryData)
            .timeout(const Duration(seconds: 15));
      }

      Get.back(result: true);
      Get.snackbar(
        'Success',
        categoryToEdit.value != null ? 'Category updated' : 'Category added',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // This catch block will now also handle TimeoutExceptions
      Get.snackbar('Error', 'Failed to save category: $e');
    } finally {
      // This will now always be called, even if a request hangs and times out.
      isLoading.value = false;
    }
  }
}