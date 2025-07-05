import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
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
    // Add listeners to refilter when filters change
    ever(filterByBrandId, (_) => applyFilters());
    ever(filterByCategoryId, (_) => applyFilters());
    debounce(searchQuery, (_) => applyFilters(), time: const Duration(milliseconds: 300));
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore.collection('products').get();
      final productList = snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
      allProducts.assignAll(productList);
      applyFilters(); // Apply initial filters (none)
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products: $e');
    } finally {
      isLoading.value = false;
    }
  }

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

  Future<void> deleteProduct(String productId) async {
    try {
      // In a real app, you must handle what happens to variants, orders containing this product etc.
      // This is a complex operation (e.g., using a Cloud Function).
      // For simplicity, we just delete the main product document.
      await _firestore.collection('products').doc(productId).delete();
      // Also delete variants (simple approach)
      final variantsSnapshot = await _firestore.collection('productVariants').where('productId', isEqualTo: productId).get();
      for(var doc in variantsSnapshot.docs) {
        await doc.reference.delete();
      }

      await fetchProducts(); // Refresh list
      Get.snackbar('Success', 'Product deleted successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: $e');
    }
  }
}