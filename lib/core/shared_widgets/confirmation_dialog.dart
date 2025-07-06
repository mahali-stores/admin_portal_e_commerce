import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/lang_keys.dart';
import '../constants/ui_constants.dart';

void showConfirmationDialog({
  required String title,
  required String message,
  required VoidCallback onConfirm,
  String? confirmText,
  String? cancelText,
}) {
  Get.dialog(
    AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(cancelText ?? LangKeys.cancel.tr),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(backgroundColor: kErrorColor),
          child: Text(confirmText ?? LangKeys.delete.tr),
        ),
      ],
    ),
  );
}
