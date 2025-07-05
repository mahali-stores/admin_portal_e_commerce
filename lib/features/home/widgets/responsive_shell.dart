import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/lang_keys.dart';
import '../../../core/constants/ui_constants.dart';
import '../../shop/brands/screens/brands_screen.dart';
import '../../shop/categories/screens/categories_screen.dart';
import '../../shop/products/screens/products_screen.dart';
import '../../shop/sales/screens/sales_screen.dart';
import '../../users/screens/users_screen.dart';
import '../screens/home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final RxInt _selectedIndex = 0.obs;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    ProductsScreen(),
    CategoriesScreen(),
    BrandsScreen(),
    SalesScreen(),
    UsersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < kMobileBreakpoint) {
          // Mobile View with BottomNavigationBar
          return Scaffold(
            body: Obx(() => _screens.elementAt(_selectedIndex.value)),
            bottomNavigationBar: Obx(
              () => BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex.value,
                onTap: (index) => _selectedIndex.value = index,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.dashboard),
                    label: LangKeys.dashboard.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.shopping_bag),
                    label: LangKeys.products.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.category),
                    label: LangKeys.categories.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.people),
                    label: LangKeys.users.tr,
                  ),
                ],
              ),
            ),
          );
        } else {
          // Desktop/Tablet View with NavigationRail
          return Scaffold(
            body: Row(
              children: <Widget>[
                Obx(
                  () => NavigationRail(
                    selectedIndex: _selectedIndex.value,
                    onDestinationSelected: (int index) =>
                        _selectedIndex.value = index,
                    labelType: NavigationRailLabelType.all,
                    extended: constraints.maxWidth > 1100,
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 40,
                        color: kPrimaryColor,
                      ),
                    ),
                    destinations: <NavigationRailDestination>[
                      NavigationRailDestination(
                        icon: const Icon(Icons.dashboard_outlined),
                        selectedIcon: const Icon(Icons.dashboard),
                        label: Text(LangKeys.dashboard.tr),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.shopping_bag_outlined),
                        selectedIcon: const Icon(Icons.shopping_bag),
                        label: Text(LangKeys.products.tr),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.category_outlined),
                        selectedIcon: const Icon(Icons.category),
                        label: Text(LangKeys.categories.tr),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.branding_watermark_outlined),
                        selectedIcon: const Icon(Icons.branding_watermark),
                        label: Text(LangKeys.brands.tr),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.local_offer_outlined),
                        selectedIcon: const Icon(Icons.local_offer),
                        label: Text(LangKeys.sales.tr),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.people_outline),
                        selectedIcon: const Icon(Icons.people),
                        label: Text(LangKeys.users.tr),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Obx(() => _screens.elementAt(_selectedIndex.value)),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
