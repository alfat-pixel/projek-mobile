import 'dart:async';
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
  String nim = '';
  String kelas = '';
  File? _imageFile;

  // Untuk waktu
  String selectedTimezone = 'WIB';
  String displayedTime = '';

  static const Map<String, int> timezoneOffsets = {
    'WIB': 7,
    'WITA': 8,
    'WIT': 9,
    'London': 0,
  };

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _startTimer();
  }

  Future<void> _loadProfileData() async {
    final user = await AuthService.getUsername();
    final storedNim = await AuthService.getNIM();
    final storedKelas = await AuthService.getKelas();
    final imagePath = await AuthService.getProfileImagePath();

    setState(() {
      username = user ?? '';
      nim = storedNim ?? '';
      kelas = storedKelas ?? '';
      if (imagePath != null) {
        _imageFile = File(imagePath);
      }
    });
  }

  void _startTimer() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now().toUtc();
    final offset = timezoneOffsets[selectedTimezone] ?? 0;
    final convertedTime = now.add(Duration(hours: offset));
    final formattedTime =
        '${convertedTime.hour.toString().padLeft(2, '0')}:${convertedTime.minute.toString().padLeft(2, '0')}:${convertedTime.second.toString().padLeft(2, '0')}';

    setState(() {
      displayedTime = formattedTime;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await AuthService.saveProfileImagePath(pickedFile.path);
    }
  }

  void _logout() async {
    await AuthService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          Row(
            children: [
              Text(selectedTimezone + ' ' + displayedTime,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: selectedTimezone,
                dropdownColor: Colors.blue,
                underline: const SizedBox(),
                iconEnabledColor: Colors.white,
                items: timezoneOffsets.keys
                    .map((tz) => DropdownMenuItem(
                          value: tz,
                          child: Text(tz,
                              style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      selectedTimezone = val;
                      _updateTime();
                    });
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
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
            const SizedBox(height: 8),
            Text('NIM: $nim', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Kelas: $kelas', style: const TextStyle(fontSize: 18)),
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