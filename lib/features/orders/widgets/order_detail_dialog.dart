import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/lang_keys.dart';
import '../controllers/orders_controller.dart';
import '../models/order_model.dart';

class OrderDetailDialog extends StatelessWidget {
  final OrderModel order;
  const OrderDetailDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final AdminOrdersController controller = Get.find();
    final RxString selectedStatus = order.status.obs;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Order Details #${order.id.substring(0, 8)}'),
      content: SizedBox(
        width: Get.width * 0.6, // Make dialog wider
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSectionTitle('Customer & Shipping'),
              _buildDetailRow('Customer:', order.shippingAddress.name),
              _buildDetailRow('Phone:', order.shippingAddress.phoneNumber),
              _buildDetailRow('Address:', '${order.shippingAddress.street}, ${order.shippingAddress.city}, ${order.shippingAddress.country}'),
              const Divider(height: 24),
              _buildSectionTitle('Order Summary'),
              _buildDetailRow('Order Date:', DateFormat.yMMMd().add_jm().format(order.orderDate)),
              _buildDetailRow('Total Amount:', '${order.totalAmount.toStringAsFixed(2)} ₪'),
              const Divider(height: 24),
              _buildSectionTitle('Items in Order'),
              ...order.items.map((item) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(item.imageUrl),
                ),
                title: Text('${item.name} (x${item.quantity})'),
                trailing: Text('${item.price.toStringAsFixed(2)} ₪'),
              )),
              const Divider(height: 24),
              _buildSectionTitle('Update Status'),
              Obx(
                    () => DropdownButtonFormField<String>(
                  value: selectedStatus.value,
                  items: controller.statusOptions
                      .where((s) => s != 'All') // 'All' is not a valid status
                      .map((String status) => DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedStatus.value = value;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Order Status',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(LangKeys.cancel.tr),
        ),
        ElevatedButton(
          onPressed: () {
            controller.updateOrderStatus(order.id, selectedStatus.value);
            Get.back(); // Close the dialog
          },
          child: Text(LangKeys.update.tr),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: Get.textTheme.titleLarge),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
