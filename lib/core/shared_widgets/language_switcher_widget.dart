import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageSwitcherWidget extends StatefulWidget {
  const LanguageSwitcherWidget({super.key, this.backgroundColor, this.selectedColor, this.textColor});

  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;

  @override
  State<LanguageSwitcherWidget> createState() => _LanguageSwitcherWidgetState();
}

class _LanguageSwitcherWidgetState extends State<LanguageSwitcherWidget> {
  bool isEnglish = Get.locale?.languageCode != 'ar'; // default to English

  void _toggleLanguage(bool english) {
    setState(() {
      isEnglish = english;
    });

    final newLocale = english
        ? const Locale('en', 'US')
        : const Locale('ar', 'SA');

    Get.updateLocale(newLocale);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.grey.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(label: 'العربية', isSelected: !isEnglish, onTap: () => _toggleLanguage(false)),
          _buildToggleButton(label: 'English', isSelected: isEnglish, onTap: () => _toggleLanguage(true)),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? (widget.selectedColor ?? Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? (widget.textColor ?? Colors.black) : Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
