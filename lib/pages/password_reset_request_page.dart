import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // TimeoutException

class PasswordResetRequestPage extends StatefulWidget {
  const PasswordResetRequestPage({super.key});

  @override
  State<PasswordResetRequestPage> createState() =>
      _PasswordResetRequestPageState();
}

class _PasswordResetRequestPageState extends State<PasswordResetRequestPage> {
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;

  static const Duration _httpTimeout = Duration(seconds: 10);

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> requestResetCode() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _show("이메일을 입력해 주세요.");
      return;
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(email)) {
      _show("올바른 이메일 형식을 입력해 주세요.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await http
          .post(
            Uri.parse("http://54.253.211.96:8000/api/request-password-reset"),
            headers: {
              'Content-Type': 'application/json',
              'accept': 'application/json',
            },
            body: jsonEncode({"email": email}),
          )
          .timeout(_httpTimeout);

      final bodyText = res.body;
      Map<String, dynamic>? bodyJson;
      try {
        bodyJson = jsonDecode(bodyText);
      } catch (_) {
        bodyJson = null; 
      }

      setState(() => isLoading = false);

      if (res.statusCode == 200) {
        _show("메일을 보냈습니다. 메일함을 확인해 주세요.");
        if (!mounted) return;
        Navigator.pushNamed(
          context,
          '/password_reset_verify',
          arguments: {'email': email},
        );
        return;
      }

      if (res.statusCode == 404) {
        _show("입력하신 정보와 일치하는 계정을 찾을 수 없습니다.");
      } else if (res.statusCode == 400) {
        final msg =
            bodyJson?['message'] ??
            bodyJson?['detail'] ??
            "요청이 올바르지 않습니다. 다시 시도해 주세요.";
        _show(msg);
      } else if (res.statusCode == 409) {
        final msg = bodyJson?['message'] ?? "이미 요청이 접수되었습니다. 잠시 후 다시 시도해 주세요.";
        _show(msg);
      } else if (res.statusCode == 429) {
        _show("요청이 많습니다. 잠시 후 다시 시도해 주세요.");
      } else if (res.statusCode >= 400 && res.statusCode < 500) {
        final msg =
            bodyJson?['message'] ??
            bodyJson?['detail'] ??
            "요청을 처리할 수 없습니다. 입력 정보를 확인해 주세요.";
        _show(msg);
      }
      else if (res.statusCode >= 500) {
        _show("일시적인 오류가 발생했습니다. 잠시 후 다시 시도해 주세요. (코드 ${res.statusCode})");
      } else {
        _show("예상치 못한 응답입니다. (코드 ${res.statusCode})");
      }
      print('[request-password-reset] status=${res.statusCode} body=$bodyText');
    } on TimeoutException {
      setState(() => isLoading = false);
      _show("요청 시간이 초과되었습니다. 네트워크를 확인한 후 다시 시도해 주세요.");
    } catch (e) {
      setState(() => isLoading = false);
      _show("네트워크 오류가 발생했습니다. 다시 시도해 주세요. ($e)");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        title: const Text(
          "비밀번호 재설정",
          style: TextStyle(color: Colors.black87, fontSize: 18),
        ),
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
              "가입한 이메일 주소를 입력해 주세요",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            Center(
              child: Container(
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
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "example@email.com",
                    hintStyle: TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Center(
              child: SizedBox(
                width: 240,
                child: ElevatedButton(
                  onPressed: isLoading ? null : requestResetCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            "메일 인증",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
