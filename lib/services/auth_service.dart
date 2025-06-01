import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyUsername = 'username';
  static const String _keyLoggedIn = 'logged_in';
  static const String _keyProfileImage = 'profile_image_path'; // key untuk foto profil
  static const String _keyNIM = 'nim';      // tambahkan key NIM
  static const String _keyKelas = 'kelas';  // tambahkan key Kelas

  // Register dengan simpan username, password, NIM, dan Kelas
  static Future<bool> register(String username, String password, String nim, String kelas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_$username', password);
    await prefs.setString(_keyNIM, nim);
    await prefs.setString(_keyKelas, kelas);
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

  static Future<String?> getNIM() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNIM);
  }

  static Future<String?> getKelas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyKelas);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyNIM);
    await prefs.remove(_keyKelas);
    await prefs.remove(_keyProfileImage);
  }

  // Fungsi simpan dan ambil path foto profil tetap ada
  static Future<void> saveProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfileImage, path);
  }

  static Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProfileImage);
  }
}
