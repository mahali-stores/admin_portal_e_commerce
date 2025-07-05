import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/services/storage_service.dart';
import '../../categories/controllers/categories_controller.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../models/product_variant_model.dart';
import '../../sales/widgets/item_selection_dialog.dart';

// Helper class to manage form controllers for each variant
class VariantFormState {
  final TextEditingController attributesController;
  final TextEditingController priceController;
  final TextEditingController stockController;
  final TextEditingController skuController;

  VariantFormState()
    : attributesController = TextEditingController(),
      priceController = TextEditingController(),
      stockController = TextEditingController(),
      skuController = TextEditingController();

  void dispose() {
    attributesController.dispose();
    priceController.dispose();
    stockController.dispose();
    skuController.dispose();
  }
}

class ProductFormController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = Get.find<StorageService>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Main product controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  // State
  final RxBool isLoading = false.obs;
  Rx<ProductModel?> productToEdit = Rx<ProductModel?>(null);

  // Brand and Categories
  final Rxn<String> selectedBrandId = Rxn<String>();
  final RxList<String> selectedCategoryIds = <String>[].obs;
  final RxList<String> selectedCategoryNames = <String>[].obs;

  // Variants
  final RxList<VariantFormState> variantForms = <VariantFormState>[].obs;

  // Images (for simplicity, only main product images are handled here)
  final RxList<dynamic> imageUrls = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ProductModel) {
      productToEdit.value = Get.arguments;
      _loadProductData(productToEdit.value!);
    } else {
      // Start with one default variant form
      addVariantForm();
    }
  }

  void _loadProductData(ProductModel product) async {
    nameController.text = product.name;
    descriptionController.text = product.description;
    selectedBrandId.value = product.brandId;
    selectedCategoryIds.assignAll(product.categoryIds);
    imageUrls.assignAll(product.imageUrls);
    _updateCategoryNames();

    // Fetch and load variants
    final variantsSnapshot = await _firestore
        .collection('productVariants')
        .where('productId', isEqualTo: product.id)
        .get();
    final variants = variantsSnapshot.docs
        .map((doc) => ProductVariantModel.fromSnapshot(doc))
        .toList();

    variantForms.clear();
    for (var variant in variants) {
      final formState = VariantFormState();
      formState.attributesController.text = variant.attributes.entries
          .map((e) => '${e.key}:${e.value}')
          .join(', ');
      formState.priceController.text = variant.price.toString();
      formState.stockController.text = variant.stockQuantity.toString();
      formState.skuController.text = variant.sku ?? '';
      variantForms.add(formState);
    }
  }

  void addVariantForm() {
    variantForms.add(VariantFormState());
  }

  void removeVariantForm(int index) {
    variantForms[index].dispose();
    variantForms.removeAt(index);
  }

  void openCategorySelectionDialog(
    BuildContext context,
    List<CategoryModel> allCategories,
  ) {
    showItemSelectionDialog(
      context: context,
      title: LangKeys.selectCategories.tr,
      allItems: allCategories
          .map((c) => SelectableItem(id: c.id, name: c.name))
          .toList(),
      initiallySelectedIds: selectedCategoryIds,
      onConfirm: (selectedIds) {
        selectedCategoryIds.assignAll(selectedIds);
        _updateCategoryNames();
      },
    );
  }

  void _updateCategoryNames() {
    final allCategories = Get.find<CategoriesController>().categories;
    final names = selectedCategoryIds
        .map((id) => allCategories.firstWhereOrNull((c) => c.id == id)?.name)
        .whereType<String>()
        .toList();
    selectedCategoryNames.assignAll(names);
  }

  Future<void> saveProduct() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final WriteBatch batch = _firestore.batch();

      // 1. Handle image uploads
      List<String> finalImageUrls = [];
      for (var image in imageUrls) {
        if (image is String) {
          // If it's a string, it's an existing URL
          finalImageUrls.add(image);
        } else if (image is Uint8List) {
          // If it's bytes, upload it and get the new URL
          String? uploadedUrl = await _storageService.uploadImageData('products/', image);
          if (uploadedUrl != null) finalImageUrls.add(uploadedUrl);
        }
      }

      // 2. Prepare product document
      final productData = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'brandId': selectedBrandId.value,
        'categoryIds': selectedCategoryIds,
        'imageUrls': finalImageUrls,
        'isFeatured': false, // Default value
      };

      DocumentReference productRef;
      if (productToEdit.value != null) {
        productRef = _firestore
            .collection('products')
            .doc(productToEdit.value!.id);
        batch.update(productRef, productData);
        // In edit mode, we should delete old variants before adding new ones
        final oldVariants = await _firestore
            .collection('productVariants')
            .where('productId', isEqualTo: productRef.id)
            .get();
        for (var doc in oldVariants.docs) {
          batch.delete(doc.reference);
        }
      } else {
        productRef = _firestore.collection('products').doc();
        batch.set(productRef, productData);
      }

      // 3. Prepare variant documents
      for (var form in variantForms) {
        final variantRef = _firestore.collection('productVariants').doc();
        final attributesMap = _parseAttributes(form.attributesController.text);

        batch.set(variantRef, {
          'productId': productRef.id,
          'attributes': attributesMap,
          'price': double.tryParse(form.priceController.text) ?? 0,
          'stockQuantity': int.tryParse(form.stockController.text) ?? 0,
          'sku': form.skuController.text.trim(),
          'imageUrls': [],
          // Per-variant images not handled in this simplified version
        });
      }

      // 4. Commit batch
      await batch.commit();

      Get.back(result: true);
      Get.snackbar(
        'Success',
        'Product saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save product: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickProductImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isNotEmpty) {
      // Convert picked XFiles into byte lists
      final bytesList = await Future.wait(files.map((file) => file.readAsBytes()).toList());
      // Add the new image data to our list
      imageUrls.addAll(bytesList);
    }
  }

  Map<String, String> _parseAttributes(String text) {
    if (text.isEmpty) return {};
    final Map<String, String> map = {};
    final pairs = text.split(',');
    for (var pair in pairs) {
      final keyValue = pair.split(':');
      if (keyValue.length == 2) {
        map[keyValue[0].trim()] = keyValue[1].trim();
      }
    }
    return map;
  }

  @override
  void onClose() {
    for (var form in variantForms) {
      form.dispose();
    }
    super.onClose();
  }
}
