import 'package:cloud_firestore/cloud_firestore.dart';

class SaleModel {
  final String id;
  String name;
  String? description;
  double discountPercentage;
  Timestamp startDate;
  Timestamp endDate;
  bool isActive;
  String appliesTo; // 'products' or 'categories'
  List<String> targetIds;

  SaleModel({
    required this.id,
    required this.name,
    this.description,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.appliesTo,
    required this.targetIds,
  });

  factory SaleModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return SaleModel(
      id: document.id,
      name: data['name'] ?? '',
      description: data['description'],
      discountPercentage: (data['discountPercentage'] ?? 0.0).toDouble(),
      startDate: data['startDate'] ?? Timestamp.now(),
      endDate: data['endDate'] ?? Timestamp.now(),
      isActive: data['isActive'] ?? false,
      appliesTo: data['appliesTo'] ?? 'products',
      targetIds: List<String>.from(data['targetIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'discountPercentage': discountPercentage,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
      'appliesTo': appliesTo,
      'targetIds': targetIds,
    };
  }

  String get status {
    final now = Timestamp.now();
    if (!isActive) return 'Inactive';
    if (now.compareTo(startDate) < 0) return 'Upcoming';
    if (now.compareTo(endDate) > 0) return 'Expired';
    return 'Active';
  }
}