import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
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

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final urlController = TextEditingController();

  final Rxn<ImageSourceData> selectedImageFile = Rxn<ImageSourceData>();
  final Rxn<String> parentCategoryId = Rxn<String>();
  final RxList<CategoryModel> availableParentCategories =
      <CategoryModel>[].obs;
  Rx<CategoryModel?> categoryToEdit = Rx<CategoryModel?>(null);

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is CategoryModel) {
      categoryToEdit.value = Get.arguments;
      _loadCategoryData(categoryToEdit.value!);
    }
    fetchParentCategories();
  }

  Future<void> fetchParentCategories() async {
    try {
      final snapshot =
      await _firestore.collection('categories').orderBy('name').get();
      final categories =
      snapshot.docs.map((doc) => CategoryModel.fromSnapshot(doc)).toList();
      if (categoryToEdit.value != null) {
        // Prevent a category from being its own parent or child of its children
        final descendants = await _getDescendants(categoryToEdit.value!.id, categories);
        categories.removeWhere((cat) => cat.id == categoryToEdit.value!.id || descendants.contains(cat.id));
      }
      availableParentCategories.assignAll(categories);
    } catch (e) {
      Get.snackbar(
          LangKeys.error.tr, '${LangKeys.couldNotFetchParentCategories.tr}: $e');
    }
  }

  Future<Set<String>> _getDescendants(String categoryId, List<CategoryModel> allCategories) async {
    Set<String> descendants = {};
    List<String> toProcess = [categoryId];
    while(toProcess.isNotEmpty) {
      String currentId = toProcess.removeAt(0);
      final children = allCategories.where((cat) => cat.parentCategoryId == currentId);
      for (var child in children) {
        if (descendants.add(child.id)) {
          toProcess.add(child.id);
        }
      }
    }
    return descendants;
  }

  void _loadCategoryData(CategoryModel category) {
    nameController.text = category.name.replaceAll(RegExp(r'—\s*'), '');
    descriptionController.text = category.description ?? '';
    if (category.imageUrl != null && category.imageUrl!.isNotEmpty) {
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

    LoadingOverlay.show(message: LangKeys.savingCategory.tr);
    try {
      String finalImageUrl = categoryToEdit.value?.imageUrl ?? '';
      final imageFile = selectedImageFile.value;
      final manualUrl = urlController.text.trim();

      if (imageFile != null && imageFile.data is Uint8List) {
        final imageData = imageFile.data as Uint8List;
        String? uploadedUrl = await _storageService
            .uploadImage(
            path: 'categories/',
            imageData: imageData,
            fileName:
            'category_${DateTime.now().millisecondsSinceEpoch}.jpg')
            .timeout(const Duration(seconds: 30));

        if (uploadedUrl == null) throw Exception(LangKeys.imageUploadTimeout.tr);
        finalImageUrl = uploadedUrl;
      } else if (manualUrl.isNotEmpty && Validators.isValidUrl(manualUrl)) {
        finalImageUrl = manualUrl;
      } else if (manualUrl.isEmpty && imageFile == null) {
        finalImageUrl = '';
      }

      final categoryData = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'imageUrl': finalImageUrl,
        'parentCategoryId': parentCategoryId.value,
      };

      if (categoryToEdit.value != null) {
        await _firestore
            .collection('categories')
            .doc(categoryToEdit.value!.id)
            .update(categoryData);
      } else {
        await _firestore.collection('categories').add(categoryData);
      }

      LoadingOverlay.hide();
      Get.back(result: true);
      Get.snackbar(
          LangKeys.success.tr,
          categoryToEdit.value != null
              ? LangKeys.categoryUpdatedSuccess.tr
              : LangKeys.categoryAddedSuccess.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kAccentColor,
          colorText: Colors.white);
    } catch (e) {
      LoadingOverlay.hide();
      Get.snackbar(LangKeys.error.tr, '${LangKeys.failedToSaveCategory.tr}: $e',
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
