// features/shop/models/category_model.dart
// I've added the 'copyWith' method to this model. This is a standard practice in
// immutable data patterns and is necessary for the logic in the CategoriesController,
// allowing us to create modified copies of a category object without changing the original.

import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? parentCategoryId;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.parentCategoryId,
  });

  factory CategoryModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return CategoryModel(
      id: document.id,
      name: data['name'] ?? '',
      description: data['description'],
      imageUrl: data['imageUrl'],
      parentCategoryId: data['parentCategoryId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'parentCategoryId': parentCategoryId,
    };
  }

  // ADDED: copyWith method to create a modified copy of the instance.
  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? parentCategoryId,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
    );
  }
}
