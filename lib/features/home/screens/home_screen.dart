import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/lang_keys.dart';
import '../../../core/shared_widgets/language_switcher_widget.dart';
import '../widgets/home_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LangKeys.homePage.tr),
        actions: const [
          // Use the new reusable widget
          LanguageSwitcherWidget(),
          SizedBox(width: 8),
        ],
      ),
      drawer: const HomeDrawer(),
      body: Center(
        child: Text(
          'Welcome to the Admin Dashboard!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}