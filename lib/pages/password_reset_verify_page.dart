import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; 

class PasswordResetVerifyPage extends StatefulWidget {
  final String email;

  const PasswordResetVerifyPage({super.key, required this.email});

  @override
  State<PasswordResetVerifyPage> createState() =>
      _PasswordResetVerifyPageState();
}

class _PasswordResetVerifyPageState extends State<PasswordResetVerifyPage> {
  final TextEditingController _codeController = TextEditingController();
  bool isLoading = false;

  static const Duration _httpTimeout = Duration(seconds: 10);

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> verifyCode() async {
    FocusScope.of(context).unfocus();
    final code = _codeController.text.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      _show("올바른 6자리 숫자를 입력해 주세요.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await http
          .post(
            Uri.parse(
              "http://54.253.211.96:8000/api/verify-password-reset-code",
            ),
            headers: {
              'Content-Type': 'application/json',
              'accept': 'application/json',
            },
            body: jsonEncode({"email": widget.email, "code": code}),
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
        _show("인증이 완료되었습니다.");
        if (!mounted) return;
        Navigator.pushNamed(
          context,
          '/password_reset_new',
          arguments: {'email': widget.email, 'code': code},
        );
        return;
      }

      if (res.statusCode == 400) {
        final msg = "입력한 정보를 다시 확인해 주세요.";
        _show(msg);
      } else if (res.statusCode == 404) {
        _show("입력하신 정보와 일치하는 요청을 찾을 수 없습니다.");
      } else if (res.statusCode == 410) {
        _show("인증코드가 만료되었습니다. 코드를 다시 받아주세요.");
      } else if (res.statusCode == 429) {
        _show("요청이 많습니다. 잠시 후 다시 시도해 주세요.");
      } else if (res.statusCode >= 400 && res.statusCode < 500) {
        final msg =
            bodyJson?['message'] ??
            bodyJson?['detail'] ??
            "요청을 처리할 수 없습니다. 잠시 후 다시 시도해 주세요.";
        _show(msg);
      }
      else if (res.statusCode >= 500) {
        _show("일시적인 오류가 발생했습니다. 잠시 후 다시 시도해 주세요. (코드 ${res.statusCode})");
      } else {
        _show("예상치 못한 응답입니다. (코드 ${res.statusCode})");
      }

      print(
        '[verify-password-reset-code] status=${res.statusCode} body=$bodyText',
      );
    } on TimeoutException {
      setState(() => isLoading = false);
      _show("요청 시간이 초과되었습니다. 네트워크 상태를 확인해 주세요.");
    } catch (e) {
      setState(() => isLoading = false);
      _show("네트워크 오류가 발생했습니다. 다시 시도해 주세요. ($e)");
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        title: const Text(
          "인증코드 입력",
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
              "메일로 전송된 인증코드를 입력해 주세요",
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
                maxLength: 6, 
                decoration: const InputDecoration(
                  counterText: "", 
                  hintText: "6자리 숫자 입력",
                  hintStyle: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
                  prefixIcon: Icon(
                    Icons.verified_user_outlined,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
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
                            "인증 확인",
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
