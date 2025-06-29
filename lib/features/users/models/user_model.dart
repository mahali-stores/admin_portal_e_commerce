import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String role;
  final Timestamp createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return UserModel(
      id: document.id,
      email: data['email'] ?? '',
      firstName: data['firstName'],
      lastName: data['lastName'],
      role: data['role'] ?? 'client',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}