import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../controllers/orders_controller.dart';
import '../models/order_model.dart';
import '../widgets/order_detail_dialog.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use lazyPut to ensure the controller is only created once
    Get.lazyPut(() => AdminOrdersController());

    return Scaffold(
      appBar: AppBar(title: Text(LangKeys.orders.tr)),
      body: RefreshIndicator(
        onRefresh: () => Get.find<AdminOrdersController>().fetchOrders(),
        child: const Column(
          children: [
            _Header(),
            Expanded(child: _OrderDataView()),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final AdminOrdersController controller = Get.find();
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Search by Order ID or Customer...',
                prefixIcon: const Icon(Icons.search, size: 20),
              ),
            ),
          ),
          const SizedBox(width: kDefaultPadding),
          Expanded(
            flex: 2,
            child: Obx(
                  () => DropdownButtonFormField<String>(
                value: controller.statusFilter.value,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.filter_list, size: 20),
                ),
                items: controller.statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.statusFilter.value = newValue;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDataView extends StatelessWidget {
  const _OrderDataView();

  @override
  Widget build(BuildContext context) {
    final AdminOrdersController controller = Get.find();
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.filteredOrders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 60, color: kSecondaryTextColor),
              const SizedBox(height: kDefaultPadding),
              Text(LangKeys.noOrdersFound.tr, style: Get.textTheme.titleMedium),
            ],
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < kMobileBreakpoint) {
            return _OrderListView(orders: controller.filteredOrders);
          } else {
            return _OrderDesktopTable(orders: controller.filteredOrders);
          }
        },
      );
    });
  }
}

// --- Mobile View ---
class _OrderListView extends StatelessWidget {
  final List<OrderModel> orders;
  const _OrderListView({required this.orders});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: kDefaultPadding),
          child: ListTile(
            contentPadding: const EdgeInsets.all(kDefaultPadding),
            title: Text('Order #${order.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(order.shippingAddress.name),
                const SizedBox(height: 8),
                Text(DateFormat.yMMMd().format(order.orderDate)),
              ],
            ),
            trailing: Chip(
              label: Text(order.status),
              backgroundColor: _getStatusColor(order.status).withOpacity(0.2),
            ),
            onTap: () => Get.dialog(OrderDetailDialog(order: order)),
          ),
        );
      },
    );
  }
}

// --- Desktop View ---
class _OrderDesktopTable extends StatelessWidget {
  final List<OrderModel> orders;
  const _OrderDesktopTable({required this.orders});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Order ID')),
              DataColumn(label: Text('Customer')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Total')),
              DataColumn(label: Text('Status')),
            ],
            rows: orders.map((order) => _buildDataRow(order)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(OrderModel order) {
    return DataRow(
      cells: [
        DataCell(Text('#${order.id.substring(0, 8)}'), onTap: () => Get.dialog(OrderDetailDialog(order: order))),
        DataCell(Text(order.shippingAddress.name), onTap: () => Get.dialog(OrderDetailDialog(order: order))),
        DataCell(Text(DateFormat.yMMMd().format(order.orderDate)), onTap: () => Get.dialog(OrderDetailDialog(order: order))),
        DataCell(Text('${order.totalAmount.toStringAsFixed(2)} ₪'), onTap: () => Get.dialog(OrderDetailDialog(order: order))),
        DataCell(
          Chip(
            label: Text(order.status),
            backgroundColor: _getStatusColor(order.status).withOpacity(0.2),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          onTap: () => Get.dialog(OrderDetailDialog(order: order)),
        ),
      ],
    );
  }
}

/// Helper function to determine chip color based on status.
Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Colors.orange;
    case 'processing':
      return Colors.blue;
    case 'shipped':
      return Colors.purple;
    case 'delivered':
      return Colors.green;
    case 'cancelled':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
