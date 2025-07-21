import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isRememberMe = false;
  bool showPassword = false;
  bool isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _tryAutoLogin() async {
    final accessToken = await _secureStorage.read(key: 'accessToken');
    final refreshToken = await _secureStorage.read(key: 'refreshToken');

    if (accessToken != null) {
      final success = await _validateAccessToken(accessToken);
      if (success) {
        Navigator.pushReplacementNamed(context, '/map');
        return;
      }
    }

    if (refreshToken != null) {
      final newAccessToken = await _refreshAccessToken(refreshToken);
      if (newAccessToken != null) {
        await _secureStorage.write(key: 'accessToken', value: newAccessToken);
        Navigator.pushReplacementNamed(context, '/map');
        return;
      }
    }

    print('자동 로그인 실패 → 로그인 페이지 유지');
  }

  Future<bool> _validateAccessToken(String accessToken) async {
    try {
      final res = await http.get(
        Uri.parse('http://54.253.211.96:8000/api/users/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      final res = await http.post(
        Uri.parse('http://54.253.211.96:8000/api/refresh'),
        headers: {
          'Authorization': 'Bearer $refreshToken',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json['access_token'];
      }
    } catch (e) {
      print('🔁 토큰 갱신 실패: $e');
    }
    return null;
  }

  Future<void> _login() async {
    final loginId = _emailController.text.trim();
    final password = _passwordController.text;

    if (loginId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디와 비밀번호를 모두 입력해주세요')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('http://54.253.211.96:8000/api/users/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'login_id': loginId, 'password': password}),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final accessToken = json['data']['access_token'];
        final refreshToken = json['data']['refresh_token'];

        await _secureStorage.write(key: 'accessToken', value: accessToken);
        await _secureStorage.write(key: 'refreshToken', value: refreshToken);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 성공')),
        );

        Navigator.pushReplacementNamed(context, '/map');
      } else if (res.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('아이디 또는 비밀번호가 틀렸습니다')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류: ${res.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildEmail() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color:  Colors.red.withOpacity(0.15),

            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        focusNode: _emailFocus,
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.black87),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 12),
          prefixIcon: Icon(Icons.account_circle_rounded, color: Colors.grey),
          hintText: '아이디',
          hintStyle: TextStyle(color: Colors.black38),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget buildPassword() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color:  Colors.red.withOpacity(0.15),

            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        focusNode: _passwordFocus,
        controller: _passwordController,
        obscureText: !showPassword,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(top: 12),
          prefixIcon: const Icon(Icons.lock, color: Colors.grey),
          hintText: '비밀번호',
          hintStyle: const TextStyle(color: Colors.black38),
          suffixIcon: IconButton(
            icon: Icon(
              showPassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                showPassword = !showPassword;
              });
            },
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/password_reset_request');
        },
        child: const Text(
          '비밀번호 찾기',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildLoginBtn() {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.red,
          elevation: 5,
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          '로그인',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildSignUpBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/signup');
        },
        child: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '계정이 없으신가요?  ',
                style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: '회원가입',
                style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '로그인',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.red),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    buildEmail(),
                    const SizedBox(height: 8),
                    buildPassword(),
                    const SizedBox(height: 3),
                    buildForgotPasswordButton(),
                    buildLoginBtn(),
                    buildSignUpBtn(),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
