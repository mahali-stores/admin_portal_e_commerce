class Validators {
  static bool isValidUrl(String url) {
    final RegExp urlRegExp = RegExp(
        r'^(?:http|https)://'
        r'(?:(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+[A-Z]{2,6}\.?|'
        r'localhost|'
        r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})'
        r'(?::\d+)?'
        r'(?:/?|[/?]\S+)$',
        caseSensitive: false);
    return urlRegExp.hasMatch(url);
  }
}