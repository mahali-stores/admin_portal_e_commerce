import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_variant_model.dart';

class ProductModel {
  final String id;
  String name;
  String description;
  List<String> imageUrls;
  String brandId;
  List<String> categoryIds;
  bool isFeatured;

  // This is for local use, not stored in Firestore directly
  List<ProductVariantModel> variants;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrls,
    required this.brandId,
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
      brandId: data['brandId'] ?? '',
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
      'categoryIds': categoryIds,
      'isFeatured': isFeatured,
    };
  }
}