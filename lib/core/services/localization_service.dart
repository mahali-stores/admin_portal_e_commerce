import 'package:get/get.dart';

// This class is now simpler. It just holds the translations given to it.
class LocalizationService extends Translations {
  final Map<String, Map<String, String>> translationKeys;

  LocalizationService({required this.translationKeys});

  @override
  Map<String, Map<String, String>> get keys => translationKeys;
}