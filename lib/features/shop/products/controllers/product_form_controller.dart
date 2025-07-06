import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/storage/storage_service_interface.dart';
import '../../../../core/shared_widgets/image_uploader_widget.dart';
import '../../../../core/shared_widgets/loading_overlay.dart';
import '../../brands/controllers/brands_controller.dart';
import '../../models/brand_model.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../models/product_variant_model.dart';

class VariantFormState {
  final String? id; // Null if it's a new variant
  final TextEditingController attributesController;
  final TextEditingController priceController;
  final TextEditingController stockController;
  final TextEditingController skuController;

  VariantFormState({this.id})
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
  final IStorageService _storageService = Get.find<IStorageService>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxBool isFeatured = false.obs;

  final RxList<ImageSourceData> productImages = <ImageSourceData>[].obs;

  final Rxn<BrandModel> selectedBrand = Rxn<BrandModel>();
  final RxList<CategoryModel> selectedCategories = <CategoryModel>[].obs;

  final RxList<VariantFormState> variantForms = <VariantFormState>[].obs;

  Rx<ProductModel?> productToEdit = Rx<ProductModel?>(null);

  @override
  void onInit() {
    super.onInit();
    // Only set the product to edit from arguments here.
    // Data loading will happen in onReady.
    if (Get.arguments is ProductModel) {
      productToEdit.value = Get.arguments;
    } else {
      addVariantForm();
    }
  }

  @override
  void onReady() {
    super.onReady();
    // It's now safe to show dialogs because the widget is rendered.
    if (productToEdit.value != null) {
      _loadProductData(productToEdit.value!);
    }
  }

  void _loadProductData(ProductModel product) async {
    LoadingOverlay.show(message: "Loading product data...");
    try {
      nameController.text = product.name;
      descriptionController.text = product.description;
      isFeatured.value = product.isFeatured;
      productImages.assignAll(product.imageUrls.map((url) => ImageSourceData(url)));

      if (product.brandId != null) {
        final brand = Get.find<BrandsController>().allBrands.firstWhereOrNull((b) => b.id == product.brandId);
        if (brand != null) selectedBrand.value = brand;
      }

      await _loadVariants(product.id);
    } catch (e) {
      Get.snackbar("Error", "Failed to load product data: $e");
    } finally {
      LoadingOverlay.hide();
    }
  }

  Future<void> _loadVariants(String productId) async {
    final variantsSnapshot = await _firestore.collection('productVariants').where('productId', isEqualTo: productId).get();
    final variants = variantsSnapshot.docs.map((doc) => ProductVariantModel.fromSnapshot(doc)).toList();
    variantForms.clear();
    for (var variant in variants) {
      final formState = VariantFormState(id: variant.id);
      formState.attributesController.text = variant.attributes.entries.map((e) => '${e.key}:${e.value}').join(', ');
      formState.priceController.text = variant.price.toString();
      formState.stockController.text = variant.stockQuantity.toString();
      formState.skuController.text = variant.sku ?? '';
      variantForms.add(formState);
    }
  }

  Future<void> pickProductImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isNotEmpty) {
      final bytesList = await Future.wait(files.map((file) => file.readAsBytes()));
      productImages.addAll(bytesList.map((bytes) => ImageSourceData(bytes)));
    }
  }

  void removeProductImage(int index) {
    productImages.removeAt(index);
  }

  void addVariantForm() => variantForms.add(VariantFormState());
  void removeVariantForm(int index) {
    variantForms[index].dispose();
    variantForms.removeAt(index);
  }

  Future<void> saveProduct() async {
    if (!formKey.currentState!.validate()) return;
    if (variantForms.isEmpty) {
      Get.snackbar("Validation Error", "A product must have at least one variant.");
      return;
    }

    LoadingOverlay.show(message: "Saving product...");
    try {
      final WriteBatch batch = _firestore.batch();

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

      final productData = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'isFeatured': isFeatured.value,
        'imageUrls': finalImageUrls,
        'brandId': selectedBrand.value?.id,
        'brand': selectedBrand.value != null ? {'brandId': selectedBrand.value!.id, 'name': selectedBrand.value!.name} : null,
        'categoryIds': selectedCategories.map((c) => c.id).toList(),
      };

      DocumentReference productRef;
      if (productToEdit.value != null) {
        productRef = _firestore.collection('products').doc(productToEdit.value!.id);
        batch.update(productRef, productData);
        final oldVariantsSnapshot = await _firestore.collection('productVariants').where('productId', isEqualTo: productRef.id).get();
        for (var doc in oldVariantsSnapshot.docs) {
          batch.delete(doc.reference);
        }
      } else {
        productRef = _firestore.collection('products').doc();
        batch.set(productRef, productData);
      }

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
        });
      }

      await batch.commit();

      LoadingOverlay.hide();
      Get.back(result: true);
      Get.snackbar('Success', 'Product saved successfully!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      LoadingOverlay.hide();
      Get.snackbar('Error', 'Failed to save product: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Map<String, String> _parseAttributes(String text) {
    if (text.isEmpty) return {};
    final Map<String, String> map = {};
    try {
      final pairs = text.split(',').where((s) => s.trim().isNotEmpty);
      for (var pair in pairs) {
        final keyValue = pair.split(':');
        if (keyValue.length == 2) {
          map[keyValue[0].trim()] = keyValue[1].trim();
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return map;
  }

  @override
  void onClose() {
    for (var form in variantForms) {
      form.dispose();
    }
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
