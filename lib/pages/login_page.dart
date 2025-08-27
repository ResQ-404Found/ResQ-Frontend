import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart'; // ✅ 뒤로가기 종료를 위해 추가

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

  static const Duration _httpTimeout = Duration(seconds: 10);

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

    if (!mounted) return;

    if (accessToken != null) {
      final success = await _validateAccessToken(accessToken);
      if (!mounted) return;
      if (success) {
        Navigator.pushReplacementNamed(context, '/map');
        return;
      }
    }

    if (refreshToken != null) {
      final newAccessToken = await _refreshAccessToken(refreshToken);
      if (!mounted) return;
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
      final res = await http
          .get(
        Uri.parse('http://54.253.211.96:8000/api/users/me'),
        headers: {'Authorization': 'Bearer $accessToken'},
      )
          .timeout(_httpTimeout);

      return res.statusCode == 200;
    } on TimeoutException {
      // ignore: avoid_print
      print('[validateToken] timeout');
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('[validateToken] error: $e');
      return false;
    }
  }

  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      final res = await http
          .post(
        Uri.parse('http://54.253.211.96:8000/api/refresh'),
        headers: {
          'Authorization': 'Bearer $refreshToken',
          'Content-Type': 'application/json',
        },
      )
          .timeout(_httpTimeout);

      final bodyText = res.body;
      Map<String, dynamic>? bodyJson;
      try {
        bodyJson = jsonDecode(bodyText);
      } catch (_) {
        bodyJson = null;
      }

      if (res.statusCode == 200) {
        return bodyJson?['access_token'];
      } else {
        // ignore: avoid_print
        print('[refresh] status=${res.statusCode} body=$bodyText');
      }
    } on TimeoutException {
      // ignore: avoid_print
      print('[refresh] timeout');
    } catch (e) {
      // ignore: avoid_print
      print('토큰 갱신 실패: $e');
    }
    return null;
  }

  Future<void> _login() async {
    final loginId = _emailController.text.trim();
    final password = _passwordController.text;

    if (loginId.isEmpty || password.isEmpty) {
      _show('아이디와 비밀번호를 모두 입력해주세요');
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await http
          .post(
        Uri.parse('http://54.253.211.96:8000/api/users/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'login_id': loginId, 'password': password}),
      )
          .timeout(_httpTimeout);

      final bodyText = res.body;
      Map<String, dynamic>? bodyJson;
      try {
        bodyJson = jsonDecode(bodyText);
      } catch (_) {
        bodyJson = null;
      }

      if (res.statusCode == 200) {
        final data = bodyJson?['data'] ?? {};
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];

        if (accessToken == null || refreshToken == null) {
          _show('응답에 토큰이 없습니다. 잠시 후 다시 시도해주세요.');
        } else {
          await _secureStorage.write(key: 'accessToken', value: accessToken);
          await _secureStorage.write(key: 'refreshToken', value: refreshToken);

          _show('로그인 성공');
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/map');
        }
      } else if (res.statusCode == 401) {
        _show('아이디 또는 비밀번호가 틀렸습니다');
      } else if (res.statusCode >= 400 && res.statusCode < 500) {
        final msg =
            bodyJson?['message'] ??
                bodyJson?['detail'] ??
                '요청이 올바르지 않습니다. (코드 ${res.statusCode})';
        _show(msg);
      } else if (res.statusCode >= 500) {
        _show('서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요. (코드 ${res.statusCode})');
      } else {
        _show('예상치 못한 응답입니다. (코드 ${res.statusCode})');
      }

      print('[signin] status=${res.statusCode} body=$bodyText');
    } on TimeoutException {
      _show('요청 시간이 초과됐습니다. 네트워크를 확인 후 다시 시도해주세요.');
    } catch (e) {
      _show('네트워크 오류: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget buildEmail() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.15),
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
            color: Colors.red.withOpacity(0.15),
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
            onPressed: () => setState(() => showPassword = !showPassword),
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
        onPressed: () => Navigator.pushNamed(context, '/password_reset_request'),
        child: const Text(
          '비밀번호 찾기',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
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
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildSignUpBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/signup'),
        child: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '계정이 없으신가요?  ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: '회원가입',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope( // ✅ 뒤로가기 눌렀을 때 앱 종료
      onWillPop: () async {
        SystemNavigator.pop(); // 앱 종료
        return false; // 라우트 pop 막기
      },
      child: Scaffold(
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
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.red,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      buildEmail(),
                      const SizedBox(height: 16),
                      buildPassword(),
                      const SizedBox(height: 3),
                      buildForgotPasswordButton(),
                      buildLoginBtn(),
                      buildSignUpBtn(),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushReplacementNamed(context, '/map'),
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
      ),
    );
  }
}
