import 'package:get/get.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/users/screens/users_screen.dart'; // <-- New

class AppRoutes {
  static const String splash = '/'; // <-- Initial route
  static const String login = '/login';
  static const String home = '/home';
  static const String users = '/users'; // <-- New

  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: users, page: () => const UsersScreen()), // <-- New
  ];
}