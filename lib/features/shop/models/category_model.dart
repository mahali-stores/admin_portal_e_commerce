import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  String name;
  String? description;
  String? imageUrl;
  String? parentCategoryId;

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
}