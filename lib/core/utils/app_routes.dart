import 'package:admin_portal_e_commerce/features/orders/screens/orders_screen.dart';
import 'package:get/get.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/shop/brands/screens/brand_form_screen.dart';
import '../../features/shop/brands/screens/brands_screen.dart';
import '../../features/shop/categories/screens/category_form_screen.dart';
import '../../features/shop/categories/screens/categories_screen.dart';
import '../../features/shop/products/screens/product_form_screen.dart';
import '../../features/shop/products/screens/products_screen.dart';
import '../../features/shop/sales/screens/sale_form_screen.dart';
import '../../features/shop/sales/screens/sales_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/users/screens/users_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String users = '/users';
  static const String brands = '/brands';
  static const String brandForm = '/brand-form';
  static const String categories = '/categories';
  static const String categoryForm = '/category-form';
  static const String products = '/products';
  static const String productForm = '/product-form'; // Add/Edit product
  static const String sales = '/sales';
  static const String saleForm = '/sale-form';
  static const String orders = '/orders';

  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: users, page: () => const UsersScreen()),
    GetPage(name: brands, page: () => const BrandsScreen()),
    GetPage(name: brandForm, page: () => const BrandFormScreen()),
    GetPage(name: categories, page: () => const CategoriesScreen()),
    GetPage(name: categoryForm, page: () => const CategoryFormScreen()),
    GetPage(name: products, page: () => const ProductsScreen()),
    GetPage(name: productForm, page: () => const ProductFormScreen()),
    GetPage(name: sales, page: () => const SalesScreen()),
    GetPage(name: saleForm, page: () => const SaleFormScreen()),
    GetPage(name: orders, page: () => const AdminOrdersScreen()),
  ];
}