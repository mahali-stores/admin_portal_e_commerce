// features/shop/models/product_model.dart
// This is the data model for a Product. It includes all the necessary fields
// that align with your database schema. The 'variants' list is for local,
// in-app use and is not stored directly in the 'products' document in Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_variant_model.dart';

class ProductModel {
  final String id;
  String name;
  String description;
  List<String> imageUrls;
  String? brandId;
  String? brandName; // For display purposes
  List<String> categoryIds;
  bool isFeatured;

  // This is for local use, not stored in Firestore directly.
  // It's populated when a product is fetched for editing.
  List<ProductVariantModel> variants;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrls,
    this.brandId,
    this.brandName,
    required this.categoryIds,
    this.isFeatured = false,
    this.variants = const [],
  });

  factory ProductModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return ProductModel(
      id: document.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      brandId: data['brandId'],
      brandName: data['brand']?['name'], // Get brand name from nested map
      categoryIds: List<String>.from(data['categoryIds'] ?? []),
      isFeatured: data['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrls': imageUrls,
      'brandId': brandId,
      // Storing brand as a map is good practice
      'brand': brandId != null && brandName != null ? {'brandId': brandId, 'name': brandName} : null,
      'categoryIds': categoryIds,
      'isFeatured': isFeatured,
    };
  }
}
