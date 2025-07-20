import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final loginIdController = TextEditingController();

  bool emailVerified = false;
  bool codeSent = false;
  bool codeVerified = false;
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool signUpCompleted = false;
  bool showLoginIdField = false;

  bool isSendingEmail = false;
  bool isVerifyingCode = false;
  bool isSubmitting = false;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    codeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    loginIdController.dispose();
    super.dispose();
  }

  Future<void> sendEmailVerification(String email) async {
    setState(() => isSendingEmail = true);
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
        setState(() {
          codeSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증 메일이 $email 로 전송되었습니다.')),
        );
      } else {
        final data = jsonDecode(response.body);
        final errorMessage = data['detail'] ?? '인증 메일 전송 실패';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    } finally {
      setState(() => isSendingEmail = false);
    }
  }

  Future<bool> verifyCode(String email, String code) async {
    setState(() => isVerifyingCode = true);
    final url = Uri.parse('http://54.253.211.96:8000/api/verify-email-code');
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
    } catch (_) {
      return false;
    } finally {
      setState(() => isVerifyingCode = false);
    }
  }

  Future<String?> getFcmToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    return await messaging.getToken();
  }

  Future<void> sendFcmTokenToServer(String token, String accessToken) async {
    final url = Uri.parse('http://54.253.211.96:8000/api/users/fcm-token');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'fcm_token': token}),
      );
      if (response.statusCode == 200) {
        print("✅ FCM 토큰 전송 성공");
      } else {
        print("❌ FCM 토큰 전송 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ FCM 전송 오류: $e");
    }
  }

  Widget buildLoadingButton({required bool isLoading, required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isLoading ? Colors.white : Colors.red,
        foregroundColor: Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: isLoading
          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(text, style: TextStyle(color: isLoading ? Colors.grey : Colors.white)),
    );
  }

  Widget buildValidatedInput({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return FormField<String>(
      validator: validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2),

                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),

                ],
              ),
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                onChanged: (_) => field.didChange(controller.text),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Colors.grey),
                  suffixIcon: suffixIcon,
                ),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(field.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 14),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(top: 120, left: 32, right: 32),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text("회원가입", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900,color: Colors.red)),
                    const SizedBox(height: 40),

                    if (!showLoginIdField) ...[
                      buildValidatedInput(
                        controller: loginIdController,
                        hintText: '아이디',
                        validator: (value) => (value == null || value.isEmpty) ? '아이디를 입력하세요' : null,
                      ),
                      buildValidatedInput(
                        controller: passwordController,
                        hintText: '비밀번호',
                        obscureText: !showPassword,
                        validator: (value) => (value == null || value.isEmpty) ? '비밀번호를 입력하세요' : null,
                        suffixIcon: IconButton(
                          icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off,color: Colors.grey,),
                          onPressed: () => setState(() => showPassword = !showPassword),
                        ),
                      ),
                      buildValidatedInput(
                        controller: confirmPasswordController,
                        hintText: '비밀번호 확인',
                        obscureText: !showConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) return '비밀번호 확인을 입력하세요';
                          if (value != passwordController.text) return '비밀번호가 일치하지 않습니다';
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(showConfirmPassword ? Icons.visibility : Icons.visibility_off,color: Colors.grey),
                          onPressed: () => setState(() => showConfirmPassword = !showConfirmPassword),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: buildValidatedInput(
                              controller: emailController,
                              hintText: '이메일',
                              validator: (value) {
                                if (value == null || value.isEmpty) return '이메일을 입력하세요';
                                if (!value.contains('@')) return '올바른 이메일 형식이 아닙니다';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 48,
                            child: buildLoadingButton(
                              isLoading: isSendingEmail,
                              text: '인증',
                              onPressed: () {
                                final enteredEmail = emailController.text.trim();
                                if (enteredEmail.isEmpty || !enteredEmail.contains('@')) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('올바른 이메일을 입력하세요')),
                                  );
                                  return;
                                }
                                sendEmailVerification(enteredEmail);
                              },
                            ),
                          ),
                        ],
                      ),
                      if (codeSent)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: buildValidatedInput(
                                controller: codeController,
                                hintText: '인증 코드 입력',
                                validator: (value) => (value == null || value.isEmpty) ? '인증 코드를 입력하세요' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 48,
                              child: buildLoadingButton(
                                isLoading: isVerifyingCode,
                                text: '확인',
                                onPressed: () async {
                                  final enteredCode = codeController.text.trim();
                                  final enteredEmail = emailController.text.trim();
                                  if (enteredCode.isEmpty || enteredEmail.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('이메일과 인증 코드를 모두 입력하세요')),
                                    );
                                    return;
                                  }
                                  final success = await verifyCode(enteredEmail, enteredCode);
                                  if (success) {
                                    setState(() {
                                      emailVerified = true;
                                      codeVerified = true;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('이메일 인증에 성공했습니다')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('인증 코드가 올바르지 않습니다')),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                    ],

                    if (showLoginIdField)
                      buildValidatedInput(
                        controller: usernameController,
                        hintText: '닉네임',
                        validator: (value) => (value == null || value.isEmpty) ? '닉네임을 입력하세요' : null,
                      ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: buildLoadingButton(
                        isLoading: isSubmitting,
                        text: showLoginIdField ? '회원가입' : '다음',
                        onPressed: () async {
                          if (!showLoginIdField) {
                            if (formKey.currentState!.validate()) {
                              if (!emailVerified) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('이메일 인증을 완료해주세요')),
                                );
                                return;
                              }
                              setState(() => showLoginIdField = true);
                            }
                            return;
                          }

                          if (formKey.currentState!.validate()) {
                            setState(() => isSubmitting = true);
                            final url = Uri.parse('http://54.253.211.96:8000/api/users/signup');
                            final body = jsonEncode({
                              'login_id': loginIdController.text.trim(),
                              'username': usernameController.text.trim(),
                              'email': emailController.text.trim(),
                              'password': passwordController.text.trim(),
                            });

                            try {
                              final response = await http.post(
                                url,
                                headers: {'Content-Type': 'application/json'},
                                body: body,
                              );

                              if (response.statusCode == 200 || response.statusCode == 201) {
                                final data = jsonDecode(response.body);
                                final accessToken = data['data']['access_token'];
                                final refreshToken = data['data']['refresh_token'];

                                if (accessToken != null && refreshToken != null) {
                                  await secureStorage.write(key: 'access_token', value: accessToken);
                                  await secureStorage.write(key: 'refresh_token', value: refreshToken);

                                  final fcmToken = await getFcmToken();
                                  if (fcmToken != null) {
                                    await sendFcmTokenToServer(fcmToken, accessToken);
                                  }

                                  setState(() => signUpCompleted = true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('회원가입에 성공했습니다')),
                                  );
                                  Navigator.pushReplacementNamed(context, '/map');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('토큰 저장 실패')),
                                  );
                                }
                              } else {
                                final data = jsonDecode(response.body);
                                final detail = data['detail'];
                                String errorMessage = '회원가입 실패';
                                if (detail is List && detail.isNotEmpty && detail.first is Map && detail.first.containsKey('msg')) {
                                  errorMessage = detail.map((e) => e['msg'].toString()).join('\n');
                                }
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
                            } finally {
                              setState(() => isSubmitting = false);
                            }
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

// 로그인 유도 텍스트
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: '이미 계정이 있으신가요?  ',
                              style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            TextSpan(
                              text: '로그인',
                              style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/map');
                      },
                      child: const Text(
                        '비회원 로그인',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),



                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }
}