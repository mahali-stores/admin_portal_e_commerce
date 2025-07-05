import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/constants/ui_constants.dart';
import 'core/services/localization_service.dart';
import 'core/utils/app_routes.dart';
import 'firebase_options.dart';
import 'initial_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // --- New, more robust translation loading ---
  final Map<String, String> en = Map<String, String>.from(
    json.decode(await rootBundle.loadString('lang/en.json')),
  );
  final Map<String, String> ar = Map<String, String>.from(
    json.decode(await rootBundle.loadString('lang/ar.json')),
  );

  final translationKeys = <String, Map<String, String>>{
    'en_US': en,
    'ar_SA': ar,
  };
  // --- End of new loading logic ---

  runApp(MyApp(translationKeys: translationKeys));
}

class MyApp extends StatelessWidget {
  // Accept the loaded keys
  final Map<String, Map<String, String>> translationKeys;

  const MyApp({super.key, required this.translationKeys});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'E-Commerce Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Enables Material Design 3 for a modern look
        scaffoldBackgroundColor: kBackgroundColor,
        primaryColor: kPrimaryColor,
        fontFamily: 'Inter',

        colorScheme: ColorScheme.light(
          primary: kPrimaryColor,
          secondary: kAccentColor,
          surface: kSurfaceColor,
          error: kErrorColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: kTextColor,
          onError: Colors.white,
        ),

        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: kTextColor,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: kTextColor,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: kTextColor,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: kTextColor),
          bodyMedium: TextStyle(fontSize: 14, color: kSecondaryTextColor),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: kTextColor,
          ),
        ),

        cardTheme: const CardThemeData(
          color: kSurfaceColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(kDefaultRadius)),
          ),
          margin: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
        ),

        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: kSurfaceColor,
          contentPadding: EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: kDefaultPadding,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(kDefaultRadius)),
            borderSide: BorderSide(
              color: Color(0xFFD1D5DB),
            ), // light grey border
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(kDefaultRadius)),
            borderSide: BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(kDefaultRadius)),
            borderSide: BorderSide(color: kPrimaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(kDefaultRadius)),
            borderSide: BorderSide(color: kErrorColor),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: kDefaultPadding,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(kDefaultRadius)),
            ),
          ),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: kSurfaceColor,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: kSecondaryTextColor,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 4,
        ),

        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: kSurfaceColor,
          selectedIconTheme: IconThemeData(color: kPrimaryColor),
          unselectedIconTheme: IconThemeData(color: kSecondaryTextColor),
          selectedLabelTextStyle: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelTextStyle: TextStyle(color: kSecondaryTextColor),
          indicatorColor: Color(
            0xFFE0F2FE,
          ), // subtle blue tint for selected indicator
        ),
      ),

      // --- Pass the loaded translations directly ---
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      translations: LocalizationService(translationKeys: translationKeys),
      // ---
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
    );
  }
}
