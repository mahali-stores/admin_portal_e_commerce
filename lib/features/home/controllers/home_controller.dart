import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../orders/models/order_model.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxBool isLoading = true.obs;

  // --- Key Metrics ---
  final RxInt userCount = 0.obs;
  final RxInt productCount = 0.obs;
  final RxInt orderCount = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;

  // --- Chart Data ---
  final RxMap<String, int> orderStatusDistribution = <String, int>{}.obs;
  final RxMap<DateTime, double> weeklySalesData = <DateTime, double>{}.obs;

  // --- Top Products ---
  final RxList<Map<String, dynamic>> topSellingProducts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllDashboardData();
  }

  Future<void> fetchAllDashboardData() async {
    isLoading.value = true;
    try {
      // Fetch all data concurrently for better performance
      await Future.wait([
        _fetchCounts(),
        _fetchOrderData(),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Could not fetch dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches simple counts for users, products, and orders.
  Future<void> _fetchCounts() async {
    final usersFuture = _firestore.collection('users').count().get();
    final productsFuture = _firestore.collection('products').count().get();
    final ordersFuture = _firestore.collection('orders').count().get();

    final results = await Future.wait([usersFuture, productsFuture, ordersFuture]);

    userCount.value = results[0].count ?? 0;
    productCount.value = results[1].count ?? 0;
    orderCount.value = results[2].count ?? 0;
  }

  /// Fetches all orders to process for revenue, status, and sales charts.
  Future<void> _fetchOrderData() async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final snapshot = await _firestore.collection('orders').get();
    final orders = snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();

    // --- Process Data ---
    double currentTotalRevenue = 0;
    final statusDist = <String, int>{};
    final salesPerDay = <DateTime, double>{};
    final productSaleCounts = <String, int>{};
    final productDetails = <String, Map<String, dynamic>>{};

    for (final order in orders) {
      // Calculate total revenue from all non-cancelled orders
      if (order.status.toLowerCase() != 'cancelled') {
        currentTotalRevenue += order.totalAmount;
      }

      // Tally order statuses
      statusDist.update(order.status, (value) => value + 1, ifAbsent: () => 1);

      // Tally weekly sales
      if (order.orderDate.isAfter(sevenDaysAgo) && order.status.toLowerCase() != 'cancelled') {
        final day = DateTime(order.orderDate.year, order.orderDate.month, order.orderDate.day);
        salesPerDay.update(day, (value) => value + order.totalAmount, ifAbsent: () => order.totalAmount);
      }

      // Tally product sales
      for (final item in order.items) {
        productSaleCounts.update(item.productId, (value) => value + item.quantity, ifAbsent: () => item.quantity);
        if (!productDetails.containsKey(item.productId)) {
          productDetails[item.productId] = {'name': item.name, 'imageUrl': item.imageUrl};
        }
      }
    }

    // --- Update Observables ---
    totalRevenue.value = currentTotalRevenue;
    orderStatusDistribution.value = statusDist;
    weeklySalesData.value = salesPerDay;

    // Process top selling products
    final sortedProducts = productSaleCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    topSellingProducts.value = sortedProducts.take(5).map((entry) {
      return {
        'name': productDetails[entry.key]?['name'] ?? 'Unknown Product',
        'imageUrl': productDetails[entry.key]?['imageUrl'] ?? '',
        'count': entry.value,
      };
    }).toList();
  }
}
