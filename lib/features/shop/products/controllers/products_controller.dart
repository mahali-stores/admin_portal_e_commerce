import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../../core/shared_widgets/loading_overlay.dart';
import '../../models/product_model.dart';

class ProductsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxBool isLoading = true.obs;
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  // Filtering state
  final RxnString filterByBrandId = RxnString();
  final RxnString filterByCategoryId = RxnString();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    // Add listeners to automatically re-apply filters when they change.
    ever(filterByBrandId, (_) => applyFilters());
    ever(filterByCategoryId, (_) => applyFilters());
    debounce(searchQuery, (_) => applyFilters(), time: const Duration(milliseconds: 300));
  }

  /// Fetches all product documents from Firestore.
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore.collection('products').orderBy('name').get();
      final productList = snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
      allProducts.assignAll(productList);
      applyFilters(); // Apply initial filters
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Applies the current filters to the product list.
  void applyFilters() {
    List<ProductModel> result = List.from(allProducts);

    // Filter by Brand
    if (filterByBrandId.value != null && filterByBrandId.value!.isNotEmpty) {
      result = result.where((p) => p.brandId == filterByBrandId.value).toList();
    }

    // Filter by Category
    if (filterByCategoryId.value != null && filterByCategoryId.value!.isNotEmpty) {
      result = result.where((p) => p.categoryIds.contains(filterByCategoryId.value)).toList();
    }

    // Filter by Search Query
    if (searchQuery.value.isNotEmpty) {
      result = result.where((p) => p.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }

    filteredProducts.assignAll(result);
  }

  /// Deletes a product and all its variants in a single atomic operation.
  Future<void> deleteProduct(String productId) async {
    LoadingOverlay.show(message: "Deleting product...");
    try {
      final WriteBatch batch = _firestore.batch();

      // 1. Delete the main product document.
      final productRef = _firestore.collection('products').doc(productId);
      batch.delete(productRef);

      // 2. Find and delete all associated variants.
      final variantsSnapshot = await _firestore.collection('productVariants').where('productId', isEqualTo: productId).get();
      for (var doc in variantsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // In a real-world scenario, you would also need to handle this product's
      // presence in carts, orders, favorites, etc. This often requires a Cloud Function
      // for full cleanup.

      // 3. Commit all delete operations.
      await batch.commit();

      LoadingOverlay.hide();
      await fetchProducts(); // Refresh list
      Get.snackbar('Success', 'Product deleted successfully.');
    } catch (e) {
      LoadingOverlay.hide();
      Get.snackbar('Error', 'Failed to delete product: $e');
    }
  }
}
