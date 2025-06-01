import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadProfileImage();
  }

  Future<void> _loadUsername() async {
    final user = await AuthService.getUsername();
    setState(() {
      username = user ?? '';
    });
  }

  Future<void> _loadProfileImage() async {
    // Contoh ambil path dari SharedPreferences atau Hive
    final path = await AuthService.getProfileImagePath();
    if (path != null) {
      setState(() {
        _imageFile = File(path);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      // Simpan path ke SharedPreferences
      await AuthService.saveProfileImagePath(pickedFile.path);
    }
  }

  void _logout() async {
    await AuthService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text('Username: $username', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
