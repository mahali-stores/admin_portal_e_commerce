import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/lang_keys.dart';
import '../../../../core/services/storage/storage_service_interface.dart';
import '../../../../core/shared_widgets/image_uploader_widget.dart';
import '../../../../core/shared_widgets/loading_overlay.dart';
import '../../../../core/utils/validators.dart';
import '../../brands/controllers/brands_controller.dart';
import '../../categories/controllers/categories_controller.dart';
import '../../models/brand_model.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../models/product_variant_model.dart';

/// Manages the state for a single variant form.
/// It no longer holds attribute names, only their corresponding values.
class VariantFormState {
  final String? id;
  // This list's indices correspond to the master attribute names list in the main controller.
  final RxList<TextEditingController> attributeValueControllers = <TextEditingController>[].obs;
  final TextEditingController priceController;
  final TextEditingController stockController;
  final TextEditingController skuController;
  final RxList<ImageSourceData> images = <ImageSourceData>[].obs;

  VariantFormState({this.id, int initialAttributeCount = 0})
      : priceController = TextEditingController(),
        stockController = TextEditingController(),
        skuController = TextEditingController() {
    // Initialize with the correct number of value fields.
    if (attributeValueControllers.isEmpty) {
      for (int i = 0; i < initialAttributeCount; i++) {
        attributeValueControllers.add(TextEditingController());
      }
    }
  }

  void dispose() {
    for (var controller in attributeValueControllers) {
      controller.dispose();
    }
    priceController.dispose();
    stockController.dispose();
    skuController.dispose();
    images.close();
  }
}

class ProductFormController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final IStorageService _storageService = Get.find<IStorageService>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // --- Master list of attribute names for the entire product ---
  final RxList<TextEditingController> productAttributeNames = <TextEditingController>[].obs;

  // --- Product Info ---
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxBool isFeatured = false.obs;
  final RxList<ImageSourceData> productImages = <ImageSourceData>[].obs;
  final RxList<TextEditingController> urlControllers = <TextEditingController>[].obs;

  // --- Categorization ---
  final Rxn<BrandModel> selectedBrand = Rxn<BrandModel>();
  final RxList<CategoryModel> selectedCategories = <CategoryModel>[].obs;

  // --- Variants ---
  final RxList<VariantFormState> variantForms = <VariantFormState>[].obs;

  // --- Editing State ---
  Rx<ProductModel?> productToEdit = Rx<ProductModel?>(null);

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ProductModel) {
      productToEdit.value = Get.arguments;
    } else {
      // For a new product, start with one attribute and one variant.
      addProductAttribute();
      addVariantForm();
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (productToEdit.value != null) {
      _loadProductData(productToEdit.value!);
    }
  }

  /// Loads all data for an existing product into the form controllers.
  void _loadProductData(ProductModel product) async {
    LoadingOverlay.show(message: LangKeys.loadingProductData.tr);
    try {
      nameController.text = product.name;
      descriptionController.text = product.description;
      isFeatured.value = product.isFeatured;
      productImages.assignAll(product.imageUrls.map((url) => ImageSourceData(url)));

      if (product.brandId != null) {
        final brand = Get.find<BrandsController>().allBrands.firstWhereOrNull((b) => b.id == product.brandId);
        if (brand != null) selectedBrand.value = brand;
      }

      if (product.categoryIds.isNotEmpty) {
        final categoriesController = Get.find<CategoriesController>();
        final existingCategories = categoriesController.flattenedCategoriesForDisplay
            .where((cat) => product.categoryIds.contains(cat.id))
            .toList();
        selectedCategories.assignAll(existingCategories);
      }

      await _loadVariants(product.id);
    } catch (e) {
      Get.snackbar(LangKeys.error.tr, "${LangKeys.failedToLoadProductData.tr}: $e");
    } finally {
      LoadingOverlay.hide();
    }
  }

  /// Fetches and populates the variant forms for an existing product.
  Future<void> _loadVariants(String productId) async {
    final variantsSnapshot = await _firestore.collection('productVariants').where('productId', isEqualTo: productId).get();
    final variants = variantsSnapshot.docs.map((doc) => ProductVariantModel.fromSnapshot(doc)).toList();

    // --- Determine the master list of attribute names from loaded data ---
    final masterAttributeSet = <String>{};
    for (final variant in variants) {
      masterAttributeSet.addAll(variant.attributes.keys);
    }
    final masterAttributeList = masterAttributeSet.toList();

    productAttributeNames.assignAll(masterAttributeList.map((name) => TextEditingController(text: name)));

    variantForms.clear();
    if (variants.isEmpty) {
      if (productAttributeNames.isEmpty) addProductAttribute();
      addVariantForm();
      return;
    }

    for (var variant in variants) {
      final formState = VariantFormState(id: variant.id, initialAttributeCount: productAttributeNames.length);

      // Populate attribute values in the correct order based on the master list
      for (int i = 0; i < masterAttributeList.length; i++) {
        final attrName = masterAttributeList[i];
        formState.attributeValueControllers[i].text = variant.attributes[attrName] ?? '';
      }

      formState.priceController.text = variant.price.toString();
      formState.stockController.text = variant.stockQuantity.toString();
      formState.skuController.text = variant.sku ?? '';
      formState.images.assignAll(variant.imageUrls.map((url) => ImageSourceData(url)));
      variantForms.add(formState);
    }
  }

  /// Adds a new attribute name to the product, automatically updating all variants.
  void addProductAttribute() {
    productAttributeNames.add(TextEditingController());
    // Add a corresponding empty value field to every existing variant
    for (final variantForm in variantForms) {
      variantForm.attributeValueControllers.add(TextEditingController());
    }
  }

  /// Removes an attribute from the product, automatically updating all variants.
  void removeProductAttribute(int index) {
    // Prevent removing the last attribute
    if (productAttributeNames.length > 1) {
      productAttributeNames[index].dispose();
      productAttributeNames.removeAt(index);

      // Remove the corresponding value field from every existing variant
      for (final variantForm in variantForms) {
        variantForm.attributeValueControllers[index].dispose();
        variantForm.attributeValueControllers.removeAt(index);
      }
    }
  }

  /// Adds a new variant form, pre-populated with the correct number of value fields.
  void addVariantForm() {
    variantForms.add(VariantFormState(initialAttributeCount: productAttributeNames.length));
  }

  /// Removes a variant form.
  void removeVariantForm(int index) {
    if (variantForms.length > 1) {
      variantForms[index].dispose();
      variantForms.removeAt(index);
    }
  }

  /// Picks product images from the device gallery.
  Future<void> pickProductImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 80);
    if (files.isNotEmpty) {
      final bytesList = await Future.wait(files.map((file) => file.readAsBytes()));
      productImages.addAll(bytesList.map((bytes) => ImageSourceData(bytes)));
    }
  }

  /// Removes a product image.
  void removeProductImage(int index) {
    productImages.removeAt(index);
  }

  /// Picks variant-specific images from the device gallery.
  Future<void> pickVariantImages(int variantIndex) async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 80);
    if (files.isNotEmpty) {
      final bytesList = await Future.wait(files.map((file) => file.readAsBytes()));
      variantForms[variantIndex].images.addAll(bytesList.map((bytes) => ImageSourceData(bytes)));
    }
  }

  /// Removes a variant-specific image.
  void removeVariantImage(int variantIndex, int imageIndex) {
    variantForms[variantIndex].images.removeAt(imageIndex);
  }

  /// Prepares the dialog for adding images via URL.
  void openUrlDialog() {
    for (var c in urlControllers) {
      c.dispose();
    }
    urlControllers.clear();
    urlControllers.add(TextEditingController());
  }

  /// Adds a new URL field to the dialog.
  void addUrlField() {
    urlControllers.add(TextEditingController());
  }

  /// Removes a URL field from the dialog.
  void removeUrlField(int index) {
    if (urlControllers.length > 1) {
      urlControllers[index].dispose();
      urlControllers.removeAt(index);
    }
  }

  /// Adds the valid URLs from the dialog to the product images.
  void addImageUrlsFromDialog() {
    final urls = urlControllers
        .map((c) => c.text.trim())
        .where((url) => url.isNotEmpty && Validators.isValidUrl(url));

    productImages.addAll(urls.map((url) => ImageSourceData(url)));

    for (var c in urlControllers) {
      c.dispose();
    }
    urlControllers.clear();
    Get.back();
  }

  /// Saves the entire product and its variants to Firestore.
  Future<void> saveProduct() async {
    if (!formKey.currentState!.validate()) return;
    if (variantForms.isEmpty) {
      Get.snackbar(LangKeys.validationError.tr, LangKeys.productMustHaveVariant.tr);
      return;
    }

    LoadingOverlay.show(message: LangKeys.savingProduct.tr);
    try {
      final WriteBatch batch = _firestore.batch();

      // 1. Handle main product images
      List<String> finalImageUrls = [];
      for (var imageSource in productImages) {
        if (imageSource.data is String) {
          finalImageUrls.add(imageSource.data);
        } else if (imageSource.data is Uint8List) {
          String? uploadedUrl = await _storageService.uploadImage(
            path: 'products/',
            imageData: imageSource.data,
            fileName: 'prod_${DateTime.now().millisecondsSinceEpoch}_${finalImageUrls.length}.jpg',
          );
          if (uploadedUrl != null) finalImageUrls.add(uploadedUrl);
        }
      }

      // 2. Prepare product data
      final productData = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'isFeatured': isFeatured.value,
        'imageUrls': finalImageUrls,
        'brandId': selectedBrand.value?.id,
        'brand': selectedBrand.value != null ? {'brandId': selectedBrand.value!.id, 'name': selectedBrand.value!.name} : null,
        'categoryIds': selectedCategories.map((c) => c.id).toList(),
      };

      // 3. Create or update product reference
      DocumentReference productRef;
      if (productToEdit.value != null) {
        productRef = _firestore.collection('products').doc(productToEdit.value!.id);
        batch.update(productRef, productData);

        // Delete old variants to replace them with the new ones
        final oldVariantsSnapshot = await _firestore.collection('productVariants').where('productId', isEqualTo: productRef.id).get();
        for (var doc in oldVariantsSnapshot.docs) {
          batch.delete(doc.reference);
        }
      } else {
        productRef = _firestore.collection('products').doc();
        batch.set(productRef, productData);
      }

      // Get the final, validated list of attribute names
      final finalAttributeNames = productAttributeNames.map((c) => c.text.trim()).toList();
      if (finalAttributeNames.any((name) => name.isEmpty)) {
        throw 'All attribute names must be filled.';
      }
      if (finalAttributeNames.toSet().length != finalAttributeNames.length) {
        throw 'Attribute names must be unique.';
      }

      // 4. Process and save each variant
      for (int i = 0; i < variantForms.length; i++) {
        final form = variantForms[i];

        // Handle variant image uploading
        List<String> finalVariantImageUrls = [];
        for (var imageSource in form.images) {
          if (imageSource.data is String) {
            finalVariantImageUrls.add(imageSource.data);
          } else if (imageSource.data is Uint8List) {
            String? uploadedUrl = await _storageService.uploadImage(
              path: 'products/${productRef.id}/variants/',
              imageData: imageSource.data,
              fileName: 'var_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
            );
            if (uploadedUrl != null) finalVariantImageUrls.add(uploadedUrl);
          }
        }

        // --- Build attributes map from the centralized names and variant-specific values ---
        final attributesMap = <String, String>{};
        for (int j = 0; j < finalAttributeNames.length; j++) {
          final attrName = finalAttributeNames[j];
          final attrValue = form.attributeValueControllers[j].text.trim();

          if (attrValue.isEmpty) {
            throw 'All attribute values for Variant ${i + 1} must be filled.';
          }
          attributesMap[attrName] = attrValue;
        }

        final variantRef = _firestore.collection('productVariants').doc();
        batch.set(variantRef, {
          'productId': productRef.id,
          'attributes': attributesMap,
          'price': double.tryParse(form.priceController.text) ?? 0,
          'stockQuantity': int.tryParse(form.stockController.text) ?? 0,
          'sku': form.skuController.text.trim(),
          'imageUrls': finalVariantImageUrls,
        });
      }

      await batch.commit();

      LoadingOverlay.hide();
      Get.back(result: true);
      Get.snackbar(LangKeys.success.tr, LangKeys.productSavedSuccess.tr, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      LoadingOverlay.hide();
      Get.snackbar(LangKeys.error.tr, '${LangKeys.failedToSaveProduct.tr}: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    // Dispose all dynamically created controllers to prevent memory leaks
    for (var controller in productAttributeNames) {
      controller.dispose();
    }
    for (var form in variantForms) {
      form.dispose();
    }
    for (var controller in urlControllers) {
      controller.dispose();
    }
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}