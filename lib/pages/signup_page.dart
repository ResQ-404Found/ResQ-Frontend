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

  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool emailVerified = false;
  // 이메일 인증 상태

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  //이메일 인증 요청 함수
  Future<void> sendEmailVerification(String email) async {
    final url = Uri.parse(
      'http://54.79.229.221:8000/api/request-verification-email?email=$email&provider=google',
    );

    try {
      final response = await http.post(url);

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
        //setState(() {
        //  emailVerified = true; // 상태 업데이트
        //});
      } else if (response.statusCode == 422) {
      // Validation Error 처리
      final responseBody = response.body;
      String errorMessage = '입력값에 문제가 있습니다.';

      try {
        final data = jsonDecode(responseBody);
        if (data is Map && data.containsKey('detail')) {
          errorMessage = data['detail'].toString();
        }
      } catch (_) {
        // JSON 디코딩 실패 시 기본 메시지 사용
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } else {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증 메일 전송 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      //네트워크 에러
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
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "회원가입",
                      style: TextStyle(
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 15),
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextFormField(
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
                        onSaved: (value) => password = value!,
                      ),
                    ),
                    SizedBox(height: 25),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextFormField(
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
                          if (value != password) {
                            return '비밀번호가 일치하지 않습니다';
                          }
                          return null;
                        },
                        onSaved: (value) => confirmPassword = value!,
                      ),
                    ),
                    SizedBox(height: 25),
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
                                final enteredEmail =
                                    emailController.text.trim();
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
                          // TODO: 이후 signup API 연동 구현
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
      ),
    );
  }
}
