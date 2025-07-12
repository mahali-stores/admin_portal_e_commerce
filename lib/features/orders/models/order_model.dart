import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shop/models/address_model.dart';
import '../../shop/models/cart_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final AddressModel shippingAddress;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.shippingAddress,
  });

  /// Converts the model to a JSON format for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'orderDate': Timestamp.fromDate(orderDate),
      'shippingAddress': shippingAddress.toJson(),
    };
  }

  /// Creates an OrderModel from a Firestore DocumentSnapshot.
  factory OrderModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: (data['items'] as List<dynamic>?)
          ?.map((itemData) =>
          CartItemModel.fromJson(itemData as Map<String, dynamic>))
          .toList() ??
          [],
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'Pending',
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      shippingAddress:
      AddressModel.fromMap(data['shippingAddress'] as Map<String, dynamic>),
    );
  }
}
