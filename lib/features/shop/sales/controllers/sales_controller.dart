import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../models/sale_model.dart';

class SalesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxBool isLoading = true.obs;
  final RxList<SaleModel> allSales = <SaleModel>[].obs;

  final RxString searchQuery = ''.obs;
  final RxList<SaleModel> filteredSales = <SaleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSales();
    debounce(
      searchQuery,
          (_) => applyFilters(),
      time: const Duration(milliseconds: 300),
    );
  }

  Future<void> fetchSales() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore
          .collection('sales')
          .orderBy('startDate', descending: true)
          .get();
      final saleList =
      snapshot.docs.map((doc) => SaleModel.fromSnapshot(doc)).toList();
      allSales.assignAll(saleList);
      applyFilters();
    } catch (e) {
      Get.snackbar(LangKeys.error.tr, '${LangKeys.failedToFetchSales.tr}: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    if (searchQuery.value.isEmpty) {
      filteredSales.assignAll(allSales);
    } else {
      filteredSales.assignAll(
        allSales
            .where(
              (sale) => sale.name.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ),
        )
            .toList(),
      );
    }
  }

  Future<void> deleteSale(String saleId) async {
    try {
      await _firestore.collection('sales').doc(saleId).delete();
      await fetchSales();
      Get.snackbar(LangKeys.success.tr, LangKeys.saleDeletedSuccess.tr);
    } catch (e) {
      Get.snackbar(LangKeys.error.tr, '${LangKeys.failedToDeleteSale.tr}: $e');
    }
  }
}
