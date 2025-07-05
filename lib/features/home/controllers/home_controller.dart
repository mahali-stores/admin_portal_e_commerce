import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxBool isLoading = false.obs;

  final RxInt userCount = 0.obs;
  final RxInt productCount = 0.obs;
  final RxInt orderCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    isLoading.value = true;
    try {
      final usersFuture = _firestore.collection('users').count().get();
      final productsFuture = _firestore.collection('products').count().get();
      final ordersFuture = _firestore.collection('orders').count().get();

      final results = await Future.wait([usersFuture, productsFuture, ordersFuture]);

      userCount.value = results[0].count ?? 0;
      productCount.value = results[1].count ?? 0;
      orderCount.value = results[2].count ?? 0;
    } catch (e) {
      Get.snackbar('Error', 'Could not fetch dashboard stats: $e');
    } finally {
      isLoading.value = false;
    }
  }
}