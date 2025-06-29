import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UsersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      QuerySnapshot<Map<String, dynamic>> userSnapshot = await _firestore.collection('users').get();
      final userList = userSnapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
      users.assignAll(userList);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: $e');
      print(e); // For debugging
    } finally {
      isLoading.value = false;
    }
  }
}