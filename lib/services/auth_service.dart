import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyUsername = 'username';
  static const String _keyLoggedIn = 'logged_in';
  static const String _keyProfileImage = 'profile_image_path'; // key untuk foto profil (path)
  static const String _keyProfileImageBase64 = 'profile_image_base64'; // key untuk foto profil (base64)
  static const String _keyNIM = 'nim';      // key untuk NIM
  static const String _keyKelas = 'kelas';  // key untuk Kelas

  // Register: simpan username, password, NIM, dan Kelas
  static Future<bool> register(String username, String password, String nim, String kelas) async {
    final prefs = await SharedPreferences.getInstance();
    // Simpan password user dengan key unik 'user_$username'
    await prefs.setString('user_$username', password);
    // Simpan data profil lainnya (NIM dan Kelas)
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

  // Cek status login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  // Ambil username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  // Ambil NIM
  static Future<String?> getNIM() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNIM);
  }

  // Ambil Kelas
  static Future<String?> getKelas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyKelas);
  }

  // Logout: hapus data login dan profil
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyNIM);
    await prefs.remove(_keyKelas);
    await prefs.remove(_keyProfileImage);
    await prefs.remove(_keyProfileImageBase64); // hapus base64 image juga
  }

  // Simpan path foto profil (untuk mobile)
  static Future<void> saveProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfileImage, path);
  }

  // Ambil path foto profil
  static Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProfileImage);
  }

  // Simpan base64 string foto profil (untuk web dan mobile)
  static Future<void> saveProfileImageBase64(String base64String) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfileImageBase64, base64String);
  }

  // Ambil base64 string foto profil
  static Future<String?> getProfileImageBase64() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProfileImageBase64);
  }
}
