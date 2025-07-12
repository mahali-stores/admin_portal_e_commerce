class CartItemModel {
  final String productId;
  final String variantId;
  final String name;
  final String imageUrl;
  final Map<String, String> attributes;
  final double price;
  int quantity;

  CartItemModel({
    required this.productId,
    required this.variantId,
    required this.name,
    required this.imageUrl,
    required this.attributes,
    required this.price,
    this.quantity = 1,
  });

  /// Convert to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'variantId': variantId,
      'name': name,
      'imageUrl': imageUrl,
      'attributes': attributes,
      'price': price,
      'quantity': quantity,
    };
  }

  /// Create a CartItemModel from a Firestore Map
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'] ?? '',
      variantId: json['variantId'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      attributes: Map<String, String>.from(json['attributes'] ?? {}),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as int?) ?? 1,
    );
  }
}
