import 'package:shared_preferences/shared_preferences.dart';

class NavigationService {
  static Future<void> setLastAccessedPage(String pageName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastAccessedPage', pageName);
  }

  static Future<String?> getLastAccessedPage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastAccessedPage');
  }
}
