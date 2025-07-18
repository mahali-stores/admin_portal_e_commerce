// features/shop/models/brand_model.dart
// This is the data model for a Brand. It's a simple class that mirrors
// the structure of your 'brands' collection in Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';

class BrandModel {
  final String id;
  String name;
  String logoUrl;
  String? description;

  BrandModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    this.description,
  });

  factory BrandModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return BrandModel(
      id: document.id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      description: data['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'description': description,
    };
  }
}
