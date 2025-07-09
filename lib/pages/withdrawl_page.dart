import 'package:flutter/material.dart';

class WithdrawalConfirmationPage extends StatelessWidget {
  const WithdrawalConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '탈퇴하기',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '정말 탈퇴하시겠습니까?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: 탈퇴 처리 로직
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('탈퇴 완료'), duration: Duration(seconds: 1)),
                    );
                    Navigator.pop(context); // 이전 화면으로
                  },
                  child: const Text(
                    '예',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 아니오 → 이전 화면으로
                  },
                  child: const Text(
                    '아니오',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
