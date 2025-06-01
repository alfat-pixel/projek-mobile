import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyUsername = 'username';
  static const String _keyLoggedIn = 'logged_in';

  // Simpel register: simpan username dan password (password disini hanya simulasi, jangan pakai ini di produksi)
  static Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    // Simpan username dan password (enkripsi disarankan di produksi)
    await prefs.setString('user_$username', password);
    return true;
  }

  // Login dengan cek username dan password
  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('user_$username');
    if (savedPassword != null && savedPassword == password) {
      await prefs.setBool(_keyLoggedIn, true);
      await prefs.setString(_keyUsername, username);
      return true;
    }
    return false;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    await prefs.remove(_keyUsername);
  }
}
