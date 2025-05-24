import 'package:flutter/material.dart';

class PasswordResetEmailSentPage extends StatelessWidget {
  final String email;

  const PasswordResetEmailSentPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('비밀번호 재설정', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 64),
              const SizedBox(height: 24),
              Text(
                email,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '비밀번호 재설정 메일이 발송되었습니다.\n확인해주세요.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('확인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
