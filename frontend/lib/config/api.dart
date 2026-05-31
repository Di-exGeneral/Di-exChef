import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String defaultUrl = 'http://10.0.2.2:8000';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url') ?? defaultUrl;
  }
}