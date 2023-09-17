import 'package:lebussd/singleton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperSharedPreferences {

  static Future<void> setString(String key, String value) async {
// Save an integer value to 'counter' key.
    await Singleton().sharedPreferences.setString(key, value);
  }

  static String getString(String key) {
    return Singleton().sharedPreferences.getString(key) ?? "";
  }
}