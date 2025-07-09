import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> sendEmailVerification(String email) async {
    final url = Uri.parse(
      'http://54.252.128.243:8000/api/request-verification-email',
    );

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
          SnackBar(
            content: Center(
              child: Text(
                '인증 메일이 $email 로 전송되었습니다.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      } else {
        String errorMessage = '인증 메일 전송 실패: ${response.statusCode}';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data.containsKey('detail')) {
            errorMessage = data['detail'].toString();
          }
        } catch (_) {}

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    }
  }

  Future<bool> verifyCode(String email, String code) async {
    final url = Uri.parse('http://54.252.128.243:8000/api/verify-email-code');

    final body = jsonEncode({"email": email, "code": code});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] == '이메일 인증 완료';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> signUp() async {
    final url = Uri.parse('http://54.252.128.243:8000/api/users/signup');

    final body = jsonEncode({
      "login_id": username,
      "email": email,
      "password": passwordController.text.trim(),
      "username": username,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? '회원가입 성공';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        Navigator.pushReplacementNamed(context, '/map');
      } else {
        String errorMessage = '회원가입 실패: ${response.statusCode}';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data.containsKey('message')) {
            errorMessage = data['message'];
          } else if (data is Map && data.containsKey('detail')) {
            errorMessage = data['detail'].toString();
          }
        } catch (_) {}
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "회원가입",
                    style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 15),

                  // 아이디
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: '아이디',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                      ),
                      validator:
                          (value) =>
                              (value == null || value.isEmpty)
                                  ? '아이디를 입력하세요'
                                  : null,
                      onSaved: (value) => username = value!,
                    ),
                  ),
                  SizedBox(height: 25),

                  // 비밀번호
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '비밀번호',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                      ),
                      validator:
                          (value) =>
                              (value == null || value.isEmpty)
                                  ? '비밀번호를 입력하세요'
                                  : null,
                    ),
                  ),
                  SizedBox(height: 25),

                  // 비밀번호 확인
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '비밀번호 확인',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호 확인을 입력하세요';
                        }
                        if (value != passwordController.text) {
                          return '비밀번호가 일치하지 않습니다';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 25),

                  // 이메일 입력 + 인증 버튼
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 80,
                            child: TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                hintText: '이메일',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 11,
                                ),
                                errorStyle: TextStyle(height: 0.8),
                                helperText: null,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '이메일을 입력하세요';
                                }
                                if (!value.contains('@')) {
                                  return '올바른 이메일 형식이 아닙니다';
                                }
                                return null;
                              },
                              onSaved: (value) => email = value!,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              final enteredEmail = emailController.text.trim();
                              if (enteredEmail.isEmpty ||
                                  !enteredEmail.contains('@')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('올바른 이메일을 입력하세요')),
                                );
                                return;
                              }
                              sendEmailVerification(enteredEmail);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 11,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              '인증',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 인증 코드 확인
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 80,
                            child: TextFormField(
                              controller: codeController,
                              decoration: InputDecoration(
                                hintText: '인증 코드 입력',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 11,
                                ),
                                helperText: null,
                                errorStyle: TextStyle(height: 0.8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              final enteredCode = codeController.text.trim();
                              final enteredEmail = emailController.text.trim();

                              if (enteredCode.isEmpty || enteredEmail.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('이메일과 인증 코드를 모두 입력하세요'),
                                  ),
                                );
                                return;
                              }

                              final success = await verifyCode(
                                enteredEmail,
                                enteredCode,
                              );
                              if (success) {
                                setState(() {
                                  emailVerified = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('이메일 인증에 성공했습니다')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('인증 코드가 올바르지 않습니다')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 11,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              '확인',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 70),
                  TextButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        if (!emailVerified) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('이메일 인증을 완료해주세요')),
                          );
                          return;
                        }
                        formKey.currentState!.save();
                        signUp();
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '회원가입',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
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
