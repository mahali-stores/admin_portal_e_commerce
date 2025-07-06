import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../../core/shared_widgets/loading_overlay.dart';
import '../../models/brand_model.dart';

class BrandsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<BrandModel> allBrands = <BrandModel>[].obs;
  final RxBool isLoading = true.obs;

  final RxString searchQuery = ''.obs;
  final RxList<BrandModel> filteredBrands = <BrandModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBrands();
    debounce(searchQuery, (_) => applyFilters(), time: const Duration(milliseconds: 300));
  }

  Future<void> fetchBrands() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore.collection('brands').orderBy('name').get();
      final brandList = snapshot.docs.map((doc) => BrandModel.fromSnapshot(doc)).toList();
      allBrands.assignAll(brandList);
      applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch brands: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    if (searchQuery.value.isEmpty) {
      filteredBrands.assignAll(allBrands);
    } else {
      filteredBrands.assignAll(allBrands
          .where((brand) => brand.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList());
    }
  }

  Future<void> deleteBrand(String brandId) async {
    LoadingOverlay.show(message: "Deleting brand...");
    try {
      final WriteBatch batch = _firestore.batch();

      // 1. Find all products associated with this brand.
      final productsSnapshot = await _firestore
          .collection('products')
          .where('brandId', isEqualTo: brandId)
          .get();

      // 2. For each product, update its brand field to null.
      for (final doc in productsSnapshot.docs) {
        batch.update(doc.reference, {'brandId': null, 'brand': null});
      }

      // 3. Delete the brand document itself.
      final brandRef = _firestore.collection('brands').doc(brandId);
      batch.delete(brandRef);

      // 4. Commit all operations atomically.
      await batch.commit();

      LoadingOverlay.hide();
      await fetchBrands(); // Refresh list
      Get.snackbar('Success', 'Brand and all associations deleted successfully');
    } catch (e) {
      LoadingOverlay.hide();
      Get.snackbar('Error', 'Failed to delete brand: $e');
    }
  }
}
