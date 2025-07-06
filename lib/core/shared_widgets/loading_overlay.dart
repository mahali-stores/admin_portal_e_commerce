import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../constants/lang_keys.dart';
import '../constants/ui_constants.dart';

class LoadingOverlay {
  static void show({String? message}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          // A modern, rounded container for the loading indicator.
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              // Using the app's card color for theme consistency.
              color: Theme.of(Get.context!).cardColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // A more subtle and modern loading animation.
                const SpinKitThreeBounce(
                  color: kPrimaryColor,
                  size: 30.0, // A slightly more compact size.
                ),
                const SizedBox(height: 24),
                Text(
                  message ?? LangKeys.pleaseWait.tr,
                  textAlign: TextAlign.center,
                  style: Get.textTheme.titleSmall, // Adjusted for better balance.
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      // The background of the overlay remains transparent as requested.
      barrierColor: Colors.black.withOpacity(0.2), // A subtle dimming effect.
    );
  }

  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}