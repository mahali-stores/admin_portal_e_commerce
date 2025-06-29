import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/services/localization_service.dart';
import 'core/utils/app_routes.dart';
import 'firebase_options.dart';
import 'initial_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- New, more robust translation loading ---
  final Map<String, String> en = Map<String, String>.from(
      json.decode(await rootBundle.loadString('lang/en.json')));
  final Map<String, String> ar = Map<String, String>.from(
      json.decode(await rootBundle.loadString('lang/ar.json')));

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
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardTheme: const CardThemeData(elevation: 2),
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