import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordResetVerifyPage extends StatefulWidget {
  final String email;

  const PasswordResetVerifyPage({super.key, required this.email});

  @override
  State<PasswordResetVerifyPage> createState() => _PasswordResetVerifyPageState();
}

class _PasswordResetVerifyPageState extends State<PasswordResetVerifyPage> {
  final TextEditingController _codeController = TextEditingController();
  bool isLoading = false;

  Future<void> verifyCode() async {
    FocusScope.of(context).unfocus();
    final code = _codeController.text.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("올바른 6자리 숫자를 입력하세요.")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://54.253.211.96:8000/api/verify-password-reset-code"),
        headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
        body: jsonEncode({"email": widget.email, "code": code}),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("인증 완료")));
        Navigator.pushNamed(context, '/password_reset_new', arguments: {
          'email': widget.email,
          'code': code,
        });
      } else {
        final msg = jsonDecode(response.body)['message'] ?? "인증 실패";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("실패: $msg")));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("네트워크 오류: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text("인증코드 입력", style: TextStyle(color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("메일로 전송된 인증코드를 입력해주세요.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text("📧 ${widget.email}", style: const TextStyle(fontSize: 14, color: Colors.deepPurple)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "인증코드",
                  hintText: "6자리 숫자 입력",
                  prefixIcon: const Icon(Icons.verified_user_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("인증 확인", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("← 이전 단계로 돌아가기", style: TextStyle(color: Colors.deepPurple)),
            )
          ],
        ),
      ),
    );
  }
}
