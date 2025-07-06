// features/shop/models/product_variant_model.dart
// This model represents a specific variant of a product, such as a different
// color or size. It is stored in a separate 'productVariants' collection in Firestore,
// linked by the 'productId'.

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductVariantModel {
  final String id;
  final String productId;
  final Map<String, String> attributes; // e.g., {'color': 'Red', 'size': 'M'}
  final double price;
  final double? salePrice;
  final String? sku;
  final int stockQuantity;
  final List<String> imageUrls;

  ProductVariantModel({
    required this.id,
    required this.productId,
    required this.attributes,
    required this.price,
    this.salePrice,
    this.sku,
    required this.stockQuantity,
    required this.imageUrls,
  });

  factory ProductVariantModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return ProductVariantModel(
      id: document.id,
      productId: data['productId'] ?? '',
      attributes: Map<String, String>.from(data['attributes'] ?? {}),
      price: (data['price'] ?? 0.0).toDouble(),
      salePrice: (data['salePrice'] as num?)?.toDouble(),
      sku: data['sku'],
      stockQuantity: data['stockQuantity'] ?? 0,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'attributes': attributes,
      'price': price,
      'salePrice': salePrice,
      'sku': sku,
      'stockQuantity': stockQuantity,
      'imageUrls': imageUrls,
    };
  }
}
