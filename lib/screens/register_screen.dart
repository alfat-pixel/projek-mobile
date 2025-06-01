import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nimController = TextEditingController();
  final _kelasController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  void _register() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final nim = _nimController.text.trim();
    final kelas = _kelasController.text.trim();

    bool registered = await AuthService.register(username, password, nim, kelas);

    setState(() {
      _isLoading = false;
    });

    if (registered) {
      setState(() {
        _successMessage = 'Registrasi berhasil! Silakan login.';
      });
    } else {
      setState(() {
        _errorMessage = 'Gagal registrasi. Coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Buat Akun Baru',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Isi form berikut untuk mendaftar',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Masukkan username' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Masukkan password' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nimController,
                          decoration: const InputDecoration(
                            labelText: 'NIM',
                            prefixIcon: Icon(Icons.confirmation_num),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Masukkan NIM' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _kelasController,
                          decoration: const InputDecoration(
                            labelText: 'Kelas',
                            prefixIcon: Icon(Icons.class_),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Masukkan Kelas' : null,
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage != null)
                          Text(_errorMessage!,
                              style: const TextStyle(
                                  color: Colors.red, fontWeight: FontWeight.w600)),
                        if (_successMessage != null)
                          Text(_successMessage!,
                              style: const TextStyle(
                                  color: Colors.green, fontWeight: FontWeight.w600)),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Register', style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Sudah punya akun? Login',
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
