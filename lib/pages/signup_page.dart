import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String username = '';
  String email = '';
  bool emailVerified = false;
  String? fcmToken;

  @override
  void initState() {
    super.initState();
    _initFcmToken();
  }

  Future<void> _initFcmToken() async {
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
      print('📲 FCM Token: $fcmToken');
    } catch (e) {
      print('❌ Failed to get FCM token: $e');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> sendEmailVerification(String email) async {
    final url = Uri.parse('http://54.253.211.96:8000/api/request-verification-email');
    final body = jsonEncode({"email": email});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증 메일이 $email 로 전송되었습니다.')),
        );
      } else {
        final data = jsonDecode(response.body);
        final error = data['detail']?.toString() ?? '오류 발생';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    }
  }

  Future<bool> verifyCode(String email, String code) async {
    final url = Uri.parse('http://54.253.211.96:8000/api/verify-email-code');
    final body = jsonEncode({"email": email, "code": code});

    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] == '이메일 인증 완료';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> signUp() async {
    final url = Uri.parse('http://54.253.211.96:8000/api/users/signup');
    final body = jsonEncode({
      "login_id": username,
      "email": email,
      "password": passwordController.text.trim(),
      "username": username,
      "fcm_token": fcmToken ?? '',
    });

    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? '회원가입 성공';

        // ✅ Show FCM Token after sign-up
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🎉 $message\n📲 FCM: $fcmToken')),
        );

        Navigator.pushReplacementNamed(context, '/map');
      } else {
        final data = jsonDecode(response.body);
        final error = data['message'] ?? data['detail']?.toString() ?? '회원가입 실패';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Text("회원가입", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Username
                  TextFormField(
                    decoration: InputDecoration(labelText: '아이디'),
                    validator: (value) => value == null || value.isEmpty ? '아이디를 입력하세요' : null,
                    onSaved: (value) => username = value!,
                  ),

                  const SizedBox(height: 15),

                  // Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: '비밀번호'),
                    validator: (value) => value == null || value.isEmpty ? '비밀번호를 입력하세요' : null,
                  ),

                  const SizedBox(height: 15),

                  // Confirm Password
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: '비밀번호 확인'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return '비밀번호 확인을 입력하세요';
                      if (value != passwordController.text) return '비밀번호가 일치하지 않습니다';
                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  // Email + 인증 button
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(labelText: '이메일'),
                          validator: (value) {
                            if (value == null || value.isEmpty) return '이메일을 입력하세요';
                            if (!value.contains('@')) return '올바른 이메일 형식이 아닙니다';
                            return null;
                          },
                          onSaved: (value) => email = value!,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => sendEmailVerification(emailController.text.trim()),
                        child: Text('인증'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // 인증 코드 입력 + 확인 button
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: codeController,
                          decoration: InputDecoration(labelText: '인증 코드 입력'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final success = await verifyCode(
                            emailController.text.trim(),
                            codeController.text.trim(),
                          );
                          if (success) {
                            setState(() => emailVerified = true);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이메일 인증 성공')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('인증 실패')));
                          }
                        },
                        child: Text('확인'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Submit Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        if (!emailVerified) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이메일 인증을 완료해주세요')));
                          return;
                        }
                        formKey.currentState!.save();
                        signUp();
                      }
                    },
                    child: const Text(
                      '회원가입',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
