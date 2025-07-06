import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/lang_keys.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/shared_widgets/loading_overlay.dart';
import '../../../core/utils/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoggingIn = false.obs;
  final Rxn<User> _firebaseUser = Rxn<User>();

  @override
  void onReady() {
    super.onReady();
    _firebaseUser.bindStream(_auth.userChanges());
    ever(_firebaseUser, _handleAuthChanged);
  }

  void _handleAuthChanged(User? user) async {
    // A small delay to allow the widget tree to settle before navigation.
    await Future.delayed(const Duration(milliseconds: 500));

    if (user == null) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      LoadingOverlay.show(message: LangKeys.verifyingUser.tr);
      if (await _isAdmin(user.uid)) {
        LoadingOverlay.hide();
        Get.offAllNamed(AppRoutes.home);
      } else {
        LoadingOverlay.hide();
        Get.snackbar(
          LangKeys.error.tr,
          LangKeys.notAdmin.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kErrorColor,
          colorText: Colors.white,
        );
        await logout();
      }
    }
  }

  Future<bool> _isAdmin(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists && doc.data()?['role'] == 'admin';
    } catch (e) {
      debugPrint("Error checking admin status: $e");
      return false;
    }
  }

  Future<void> login(String email, String password) async {
    isLoggingIn.value = true;
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // The _handleAuthChanged listener will now handle the redirect.
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        LangKeys.error.tr,
        e.message ?? LangKeys.loginFailed.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kErrorColor,
        colorText: Colors.white,
      );
    } finally {
      isLoggingIn.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
