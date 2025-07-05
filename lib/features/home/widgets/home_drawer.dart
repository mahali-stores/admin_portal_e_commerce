import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/lang_keys.dart';
import '../../../core/utils/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Text(
              LangKeys.dashboard.tr,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard,
            title: LangKeys.dashboard.tr,
            onTap: () => Get.toNamed(AppRoutes.home),
          ),
          _buildDrawerItem(
            icon: Icons.people,
            title: LangKeys.users.tr,
            onTap: () => Get.toNamed(AppRoutes.users),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.shopping_bag,
            title: LangKeys.products.tr,
            onTap: () => Get.toNamed(AppRoutes.products),
          ),
          _buildDrawerItem(
            icon: Icons.category,
            title: LangKeys.categories.tr,
            onTap: () => Get.toNamed(AppRoutes.categories),
          ),
          _buildDrawerItem(
            icon: Icons.branding_watermark,
            title: LangKeys.brands.tr,
            onTap: () => Get.toNamed(AppRoutes.brands),
          ),
          _buildDrawerItem(
            icon: Icons.local_offer,
            title: LangKeys.sales.tr,
            onTap: () => Get.toNamed(AppRoutes.sales),
          ),
          _buildDrawerItem(
            icon: Icons.receipt_long,
            title: LangKeys.orders.tr,
            onTap: () =>
                Get.snackbar('Info', 'Orders page not implemented yet.'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(LangKeys.logout.tr),
            onTap: () => authController.logout(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        // Corrected Logic: Close drawer before navigating.
        Get.back();
        onTap();
      },
    );
  }
}
