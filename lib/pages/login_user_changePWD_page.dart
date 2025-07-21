import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/api/http_client.dart';

class LoginUserChangePWDPage extends StatefulWidget {
  const LoginUserChangePWDPage({super.key});

  @override
  State<LoginUserChangePWDPage> createState() => _LoginUserChangePWDPageState();
}

class _LoginUserChangePWDPageState extends State<LoginUserChangePWDPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool isLoading = false;
  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  String? currentPasswordError = null;
  String? newPasswordError = null;
  String? confirmPasswordError = null;

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 초기화
    setState(() {
      currentPasswordError = null;
      newPasswordError = null;
      confirmPasswordError = null;
    });

    // 빈 칸이 있는 경우
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        currentPasswordError = currentPassword.isEmpty ? "현재 비밀번호를 입력하세요" : null;
        newPasswordError = newPassword.isEmpty ? "새 비밀번호를 입력하세요" : null;
        confirmPasswordError = confirmPassword.isEmpty ? "비밀번호 확인을 입력하세요" : null;
      });
      return;
    }

    // 비밀번호 확인이 일치하지 않는 경우
    if (newPassword != confirmPassword) {
      setState(() {
        confirmPasswordError = "새 비밀번호가 일치하지 않습니다."; // 메시지 설정
      });
      return;
    }

    setState(() => isLoading = true);

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');

    if (token == null) {
      setState(() {
        currentPasswordError = "로그인이 필요합니다."; // 메시지 설정
      });
      setState(() => isLoading = false);
      return;
    }

    final response = await HttpClient.patchUserUpdate(
      token: token,
      data: {
        "password": {
          "current_password": currentPassword,
          "new_password": newPassword,
        }
      },
    );

    setState(() => isLoading = false);

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("비밀번호가 변경되었습니다.")),
      );
      Navigator.pop(context);  // 마이페이지로 돌아가기
    } else {
      // 기존 비밀번호가 틀린 경우 처리
      if (response['message'] == "현재 비밀번호가 틀립니다.") {
        setState(() {
          currentPasswordError = "현재 비밀번호가 일치하지 않습니다."; // 기존 비밀번호가 틀린 경우 메시지 설정
        });
      } else {
        setState(() {
          currentPasswordError = response['message'] ?? '비밀번호 변경 실패'; // 실패 메시지 설정
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text("비밀번호 변경", style: TextStyle(color: Colors.black87, fontSize: 18)),
        backgroundColor: Color(0xFFFAFAFA),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "새로운 비밀번호를 입력해주세요",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),

            // 현재 비밀번호 입력 박스
            _buildPasswordField(_currentPasswordController, "현재 비밀번호", showCurrentPassword, () {
              setState(() {
                showCurrentPassword = !showCurrentPassword;
              });
            }, Icons.verified_user_outlined, currentPasswordError),

            const SizedBox(height: 10),

            // 새 비밀번호 입력 박스
            _buildPasswordField(_newPasswordController, "새 비밀번호 (8자 이상)", showNewPassword, () {
              setState(() {
                showNewPassword = !showNewPassword;
              });
            }, Icons.lock, newPasswordError),

            const SizedBox(height: 10),

            // 비밀번호 확인 박스
            _buildPasswordField(_confirmPasswordController, "새 비밀번호 확인", showConfirmPassword, () {
              setState(() {
                showConfirmPassword = !showConfirmPassword;
              });
            }, Icons.lock_person_outlined, confirmPasswordError),

            const SizedBox(height: 30),

            // 비밀번호 변경 버튼
            Center(
              child: SizedBox(
                width: 240,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text(
                    "비밀번호 변경하기",
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

  // 비밀번호 입력 필드 (비밀번호 변경 페이지와 동일한 UI 스타일)
  Widget _buildPasswordField(TextEditingController controller, String hintText, bool isPasswordVisible, VoidCallback toggleVisibility, IconData icon, String? errorText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            controller: controller,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
              prefixIcon: Icon(icon, color: Colors.grey),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: toggleVisibility,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
        if (errorText != null && errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 20),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
