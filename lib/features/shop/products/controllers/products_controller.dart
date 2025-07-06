import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/shared_widgets/loading_overlay.dart';
import '../../models/product_model.dart';

class ProductsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxBool isLoading = true.obs;
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  final RxnString filterByBrandId = RxnString();
  final RxnString filterByCategoryId = RxnString();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    ever(filterByBrandId, (_) => applyFilters());
    ever(filterByCategoryId, (_) => applyFilters());
    debounce(searchQuery, (_) => applyFilters(),
        time: const Duration(milliseconds: 300));
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final snapshot =
      await _firestore.collection('products').orderBy('name').get();
      final productList =
      snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
      allProducts.assignAll(productList);
      applyFilters();
    } catch (e) {
      Get.snackbar(LangKeys.error.tr, '${LangKeys.failedToFetchProducts.tr}: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    List<ProductModel> result = List.from(allProducts);

    if (filterByBrandId.value != null && filterByBrandId.value!.isNotEmpty) {
      result = result.where((p) => p.brandId == filterByBrandId.value).toList();
    }

    if (filterByCategoryId.value != null &&
        filterByCategoryId.value!.isNotEmpty) {
      result = result
          .where((p) => p.categoryIds.contains(filterByCategoryId.value))
          .toList();
    }

    if (searchQuery.value.isNotEmpty) {
      result = result
          .where((p) =>
          p.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    filteredProducts.assignAll(result);
  }

  Future<void> deleteProduct(String productId) async {
    LoadingOverlay.show(message: LangKeys.deletingProduct.tr);
    try {
      final WriteBatch batch = _firestore.batch();

      final productRef = _firestore.collection('products').doc(productId);
      batch.delete(productRef);

      final variantsSnapshot = await _firestore
          .collection('productVariants')
          .where('productId', isEqualTo: productId)
          .get();
      for (var doc in variantsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      LoadingOverlay.hide();
      await fetchProducts();
      Get.snackbar(LangKeys.success.tr, LangKeys.productDeletedSuccess.tr);
    } catch (e) {
      LoadingOverlay.hide();
      Get.snackbar(LangKeys.error.tr, '${LangKeys.failedToDeleteProduct.tr}: $e');
    }
  }
}
