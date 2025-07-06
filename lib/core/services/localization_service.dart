import 'package:get/get.dart';

class LocalizationService extends Translations {
  final Map<String, Map<String, String>> translationKeys;

  LocalizationService({required this.translationKeys});

  @override
  Map<String, Map<String, String>> get keys => translationKeys;
}