import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/ui_constants.dart';

class FormSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const FormSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: kDefaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Get.textTheme.titleLarge,
            ),
            const Divider(height: kDefaultPadding * 1.5, thickness: 0.5),
            child,
          ],
        ),
      ),
    );
  }
}