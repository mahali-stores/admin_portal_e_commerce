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

  runApp(MyApp(translationKeys: translationKeys));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>> translationKeys;

  const MyApp({super.key, required this.translationKeys});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'E-Commerce Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      translations: LocalizationService(translationKeys: translationKeys),
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
    );
  }

  ThemeData buildThemeData() {
    return ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBackgroundColor,
        primaryColor: kPrimaryColor,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.light(
          primary: kPrimaryColor,
          secondary: kAccentColor,
          surface: kSurfaceColor,
          background: kBackgroundColor,
          error: kErrorColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: kTextColor,
          onBackground: kTextColor,
          onError: Colors.white,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: kTextColor),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kTextColor),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: kTextColor),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kTextColor),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kTextColor),
          bodyLarge: TextStyle(fontSize: 16, color: kTextColor),
          bodyMedium: TextStyle(fontSize: 14, color: kSecondaryTextColor),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kSurfaceColor,
          elevation: 0,
          foregroundColor: kTextColor,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: kTextColor,
            fontFamily: 'Inter',
          ),
        ),
        cardTheme: CardThemeData(
          color: kSurfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(kDefaultRadius)),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: kDefaultPadding),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(kDefaultRadius)),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(kDefaultRadius)),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(kDefaultRadius)),
            borderSide: BorderSide(color: kPrimaryColor, width: 2),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(kDefaultRadius)),
            borderSide: BorderSide(color: kErrorColor),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            elevation: 1,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: kDefaultPadding),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(kDefaultRadius)),
            ),
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kTextColor,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: kDefaultPadding),
            side: BorderSide(color: Colors.grey.shade300),
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
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: kSurfaceColor,
          selectedIconTheme: const IconThemeData(color: kPrimaryColor),
          unselectedIconTheme: const IconThemeData(color: kSecondaryTextColor),
          selectedLabelTextStyle: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600),
          unselectedLabelTextStyle: const TextStyle(color: kSecondaryTextColor),
          indicatorColor: kPrimaryColor.withOpacity(0.1),
        ),
        dialogTheme: DialogThemeData(
            backgroundColor: kSurfaceColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kDefaultRadius)
            )
        )
    );
  }
}