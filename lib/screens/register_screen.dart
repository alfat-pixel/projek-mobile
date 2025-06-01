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
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (val) => val == null || val.isEmpty ? 'Masukkan username' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (val) => val == null || val.isEmpty ? 'Masukkan password' : null,
              ),
              TextFormField(
                controller: _nimController,
                decoration: const InputDecoration(labelText: 'NIM'),
                validator: (val) => val == null || val.isEmpty ? 'Masukkan NIM' : null,
              ),
              TextFormField(
                controller: _kelasController,
                decoration: const InputDecoration(labelText: 'Kelas'),
                validator: (val) => val == null || val.isEmpty ? 'Masukkan Kelas' : null,
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              if (_successMessage != null)
                Text(_successMessage!, style: const TextStyle(color: Colors.green)),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
