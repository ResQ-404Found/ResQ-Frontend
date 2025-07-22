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
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Color(0xFFFAFAFA),
        title: const Text("인증코드 입력", style: TextStyle(color: Colors.black87,fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "메일로 전송된 인증코드를 입력해주세요",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              width: 340,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "6자리 숫자 입력",
                  hintStyle: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
                  prefixIcon: Icon(Icons.verified_user_outlined, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: 240,
                child: ElevatedButton(
                  onPressed: isLoading ? null : verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                    "인증 확인",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
