import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/lang_keys.dart' show LangKeys;
import '../../../core/constants/ui_constants.dart';
import '../../../core/shared_widgets/language_switcher_widget.dart';
import '../widgets/animated_stat_card.dart';
import '../widgets/order_status_pie_chart.dart';
import '../widgets/sales_line_chart.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_drawer.dart';
import '../widgets/top_products_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '₪');

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
          onRefresh: () => controller.fetchAllDashboardData(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              children: [
                // --- Animated Stat Cards ---
                GridView.count(
                  crossAxisCount: context.isPhone ? 2 : 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: kDefaultPadding,
                  mainAxisSpacing: kDefaultPadding,
                  childAspectRatio: context.isPhone ? 1.2 : 1.5,
                  children: [
                    AnimatedStatCard(
                      icon: Icons.attach_money,
                      title: 'Total Revenue',
                      end: controller.totalRevenue.value,
                      color: Colors.green,
                      formatter: (val) => currencyFormat.format(val),
                    ),
                    AnimatedStatCard(
                      icon: Icons.receipt_long,
                      title: 'Total Sales',
                      end: controller.orderCount.value.toDouble(),
                      color: Colors.orange,
                    ),
                    AnimatedStatCard(
                      icon: Icons.people,
                      title: 'Total Users',
                      end: controller.userCount.value.toDouble(),
                      color: Colors.blue,
                    ),
                    AnimatedStatCard(
                      icon: Icons.shopping_bag,
                      title: 'Total Products',
                      end: controller.productCount.value.toDouble(),
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: kDefaultPadding * 1.5),

                // --- Charts and Top Products ---
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < kMobileBreakpoint;
                    if (isMobile) {
                      return Column(
                        children: [
                          _buildChartCard(title: 'Weekly Sales', child: SalesLineChart(salesData: controller.weeklySalesData)),
                          const SizedBox(height: kDefaultPadding),
                          _buildChartCard(title: 'Order Status', child: OrderStatusPieChart(statusData: controller.orderStatusDistribution)),
                          const SizedBox(height: kDefaultPadding),
                          _buildChartCard(title: 'Top Selling Products', child: TopProductsList(products: controller.topSellingProducts)),
                        ],
                      );
                    } else {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildChartCard(title: 'Weekly Sales', child: SalesLineChart(salesData: controller.weeklySalesData)),
                          ),
                          const SizedBox(width: kDefaultPadding),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildChartCard(title: 'Order Status', child: OrderStatusPieChart(statusData: controller.orderStatusDistribution)),
                                const SizedBox(height: kDefaultPadding),
                                _buildChartCard(title: 'Top Selling Products', child: TopProductsList(products: controller.topSellingProducts)),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildChartCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Get.textTheme.titleLarge),
            const SizedBox(height: kDefaultPadding),
            child,
          ],
        ),
      ),
    );
  }
}
