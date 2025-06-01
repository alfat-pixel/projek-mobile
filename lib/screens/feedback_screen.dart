import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kesan & Pesan'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Saran: Semoga kelas TPM semakin jaya lagi.\n'
          'Kesan: Sangat menyenangkan, bukan? hehe',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
