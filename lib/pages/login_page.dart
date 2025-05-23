import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'password_reset.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isRememberMe = false; //체크박스 상태 저장
  // 입력된 아이디/비밀번호를 가져오기 위해 사용 (밑줄)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Widget buildEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '아이디',
          style: TextStyle(
              color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
            ],
          ),
          height: 60,
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.black87),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14),
              prefixIcon: Icon(Icons.account_circle_rounded, color: Colors.black87),
              hintText: '아이디',
              hintStyle: TextStyle(color: Colors.black38),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '비밀번호',
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
            ],
          ),
          height: 60,
          child: TextField(
            controller: _passwordController,
            obscureText: true, // 입력 값이 가려짐 
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14),
              prefixIcon: Icon(Icons.lock, color: Colors.black87),
              hintText: '비밀번호',
              hintStyle: TextStyle(color: Colors.black38),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildForgotPassBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/password-reset'); // "비밀번호 기억 못 하시나요?" 버튼 → 비밀번호 재설정 페이지로 이동
        },
        child: const Text(
          '비밀번호 기억 못 하시나요?',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildRememberCb() {
    return Row(
      children: [
        Checkbox(
          value: isRememberMe,
          checkColor: Colors.black,
          activeColor: Colors.white,
          onChanged: (value) {
            setState(() {
              isRememberMe = value ?? false;
            });
          },
        ),
        const Text(
          '저장하겠습니까?',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget buildLoginBtn() { // 이 버튼을 누르면 로그인 API 요청이 실행됨
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final loginId = _emailController.text.trim();
          final password = _passwordController.text;

          if (loginId.isEmpty || password.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('아이디와 비밀번호를 모두 입력해주세요')),
            );
            return;
          }

          final url = Uri.parse('http://54.79.229.221:8000/api/users/signin');

          try {
            final response = await http.post(
              url,
              headers: {
                'accept' : 'application/json',
                'Content-Type': 'application/json'},
              body: jsonEncode({
                'login_id': loginId,
                'password': password,
              }),
            );

            if (response.statusCode == 200) {
              final json = jsonDecode(response.body);
              final accessToken = json['data']['accessToken'];
              final refreshToken = json['data']['refreshToken'];

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그인 성공')),
              );

              Navigator.pushReplacementNamed(context, '/main');
            } else if (response.statusCode == 401) {
              final error = jsonDecode(response.body);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('로그인 실패: 아이디 또는 비밀번호가 틀렸습니다')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('서버 오류: $response.statusCode')),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('네트워크 오류: {e}')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.white,
          elevation: 5,
        ),
        child: const Text(
          '로그인',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildSignUpBtn() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/signup');
      },
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '가입한 적이 없으신가요? ',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: '회원가입',
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: GestureDetector(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 120),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '로그인',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 50),
                  buildEmail(),
                  const SizedBox(height: 20),
                  buildPassword(),
                  buildForgotPassBtn(),
                  buildRememberCb(),
                  buildLoginBtn(),
                  buildSignUpBtn(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* 

전체 흐름 요약

1. 로그인 화면 표시
2. 사용자가 아이디 & 비밀번호 입력
3. "로그인" 버튼 클릭
   → 서버에 POST 요청 (http://54.79.229.221:8000/api/users/signin)
4. 응답 코드에 따라
   - 성공: /main으로 이동
   - 실패: 오류 메시지 표시
5. "비밀번호 잊음" → /password-reset로 이동
6. "회원가입" → /signup으로 이동

*/
