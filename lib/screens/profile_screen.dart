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
    final primaryColor = Colors.deepPurple.shade600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Profil'),
        actions: [
          Row(
            children: [
              Text(
                '$selectedTimezone $displayedTime',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: selectedTimezone,
                dropdownColor: primaryColor,
                underline: const SizedBox(),
                iconEnabledColor: Colors.white,
                items: timezoneOffsets.keys
                    .map((tz) => DropdownMenuItem(
                          value: tz,
                          child: Text(tz, style: const TextStyle(color: Colors.white)),
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
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: primaryColor.withOpacity(0.2),
                backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? Icon(Icons.person, size: 80, color: primaryColor)
                    : null,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              username,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoRow('NIM', nim),
            _buildInfoRow('Kelas', kelas),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
