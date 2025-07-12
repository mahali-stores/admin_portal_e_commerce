import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/lang_keys.dart';
import '../../../core/shared_widgets/language_switcher_widget.dart';
import '../../../core/utils/app_routes.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_drawer.dart';
import '../widgets/stat_card_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    return Scaffold(
      appBar: AppBar(
        title: Text(LangKeys.dashboard.tr),
        actions: const [
          LanguageSwitcherWidget(),
          SizedBox(width: 8),
        ],
      ),
      drawer: const HomeDrawer(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () => controller.fetchStats(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LangKeys.welcomeAdmin.tr,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: context.isPhone ? 2 : 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    StatCard(
                      icon: Icons.people,
                      title: LangKeys.totalUsers.tr,
                      count: controller.userCount.value.toString(),
                      color: Colors.blue,
                      onTap: () => Get.toNamed(AppRoutes.users),
                    ),
                    StatCard(
                      icon: Icons.shopping_bag,
                      title: LangKeys.totalProducts.tr,
                      count: controller.productCount.value.toString(),
                      color: Colors.green,
                      onTap: () => Get.toNamed(AppRoutes.products),
                    ),
                    StatCard(
                      icon: Icons.receipt_long,
                      title: LangKeys.totalOrders.tr,
                      count: controller.orderCount.value.toString(),
                      color: Colors.orange,
                      // --- UPDATED: Navigate to the new orders route ---
                      onTap: () => Get.toNamed(AppRoutes.orders),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
