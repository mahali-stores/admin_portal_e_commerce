import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../models/order_model.dart';

class AdminOrdersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = true.obs;
  final RxList<OrderModel> allOrders = <OrderModel>[].obs;
  final RxList<OrderModel> filteredOrders = <OrderModel>[].obs;

  // Filtering State
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'All'.obs;
  final List<String> statusOptions = ['All', 'Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    // Re-apply filters whenever the search query or status filter changes
    debounce(searchQuery, (_) => applyFilters(), time: const Duration(milliseconds: 300));
    ever(statusFilter, (_) => applyFilters());
  }

  /// Fetches all orders from the Firestore database.
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore.collection('orders').orderBy('orderDate', descending: true).get();
      final orderList = snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();
      allOrders.assignAll(orderList);
      applyFilters(); // Apply initial filters
    } catch (e) {
      Get.snackbar(LangKeys.error.tr, 'Failed to fetch orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Filters the master list of orders based on current search and status filters.
  void applyFilters() {
    List<OrderModel> result = allOrders;

    // Apply status filter
    if (statusFilter.value != 'All') {
      result = result.where((order) => order.status.toLowerCase() == statusFilter.value.toLowerCase()).toList();
    }

    // Apply search query filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((order) {
        return order.id.toLowerCase().contains(query) ||
            order.shippingAddress.name.toLowerCase().contains(query);
      }).toList();
    }

    filteredOrders.assignAll(result);
  }

  /// Updates the status of a specific order and adjusts stock levels accordingly.
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final orderRef = _firestore.collection('orders').doc(orderId);
        final orderSnapshot = await transaction.get(orderRef);

        if (!orderSnapshot.exists) {
          throw Exception("Order not found!");
        }

        final order = OrderModel.fromSnapshot(orderSnapshot);
        final oldStatus = order.status;

        // --- Stock Management Logic ---
        final fulfilledStates = ['shipped', 'delivered'];
        final isMovingToFulfilled = fulfilledStates.contains(newStatus.toLowerCase());
        final wasAlreadyFulfilled = fulfilledStates.contains(oldStatus.toLowerCase());

        // Only decrement stock if moving to a "fulfilled" state from a "non-fulfilled" state.
        if (isMovingToFulfilled && !wasAlreadyFulfilled) {
          for (final item in order.items) {
            final variantRef = _firestore.collection('productVariants').doc(item.variantId);
            final variantSnapshot = await transaction.get(variantRef);

            if (variantSnapshot.exists) {
              final currentStock = (variantSnapshot.data()?['stockQuantity'] as int?) ?? 0;
              final newStock = currentStock - item.quantity;
              transaction.update(variantRef, {'stockQuantity': newStock >= 0 ? newStock : 0});
            }
          }
        }
        // --- End of Stock Management Logic ---

        // Update the order status itself
        transaction.update(orderRef, {'status': newStatus});
      });

      Get.snackbar(LangKeys.success.tr, 'Order status updated successfully.');
      await fetchOrders(); // Refresh the list to show the change
    } catch (e) {
      Get.snackbar(LangKeys.error.tr, 'Failed to update order status: $e');
    }
  }
}
