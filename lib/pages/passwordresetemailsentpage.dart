import 'package:flutter/material.dart';

class PasswordResetEmailSentPage extends StatelessWidget {
  final String email;

  const PasswordResetEmailSentPage({super.key, required this.email}); // 전달받은 이메일 주소를 보여주기 위해 required 파라미터로 받음

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

/* 전체 흐름 요약 

1. 입력된 이메일 주소 표시
2. 메일 발송됨” 안내 문구
3. 확인 버튼 → 이전 화면으로 이동

*/