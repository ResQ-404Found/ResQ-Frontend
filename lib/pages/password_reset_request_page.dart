import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordResetRequestPage extends StatefulWidget {
  const PasswordResetRequestPage({super.key});

  @override
  State<PasswordResetRequestPage> createState() => _PasswordResetRequestPageState();
}

class _PasswordResetRequestPageState extends State<PasswordResetRequestPage> {
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;

  Future<void> requestResetCode() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("이메일을 입력하세요.")));
      return;
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("올바른 이메일 형식을 입력하세요.")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://54.253.211.96:8000/api/request-password-reset"),
        headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
        body: jsonEncode({"email": email}),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("메일 전송 완료!")));
        Navigator.pushNamed(context, '/password_reset_verify', arguments: {'email': email});
      } else {
        final msg = jsonDecode(response.body)['message'] ?? "오류 발생";
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
        title: const Text("비밀번호 재설정", style: TextStyle(color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("가입한 이메일 주소를 입력해 주세요", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "이메일",
                  hintText: "example@email.com",
                  prefixIcon: const Icon(Icons.email_outlined),
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
                onPressed: isLoading ? null : requestResetCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("비밀번호 재설정 메일 받기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("← 로그인으로 돌아가기", style: TextStyle(color: Colors.deepPurple)),
            )
          ],
        ),
      ),
    );
  }
}
