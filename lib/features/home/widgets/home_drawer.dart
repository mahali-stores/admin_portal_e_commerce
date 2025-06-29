import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/lang_keys.dart';
import '../../../core/utils/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Find the AuthController instance
    final AuthController authController = Get.find();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              LangKeys.dashboard.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: Text(LangKeys.users.tr),
            onTap: () {
              Get.back(); // Close drawer first
              Get.toNamed(AppRoutes.users); // Navigate to Users screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: Text(LangKeys.users.tr),
            onTap: () {
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: Text(LangKeys.products.tr),
            onTap: () {
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text(LangKeys.orders.tr),
            onTap: () {
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(LangKeys.categories.tr),
            onTap: () {
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.branding_watermark),
            title: Text(LangKeys.brands.tr),
            onTap: () {
              Get.back();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(LangKeys.logout.tr),
            onTap: () {
              authController.logout();
            },
          ),
        ],
      ),
    );
  }
}