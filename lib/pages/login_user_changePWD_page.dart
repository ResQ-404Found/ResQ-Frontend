import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/api/http_client.dart';

class LoginUserChangePWDPage extends StatefulWidget {
  const LoginUserChangePWDPage({super.key});

  @override
  State<LoginUserChangePWDPage> createState() => _LoginUserChangePWDPageState();
}

class _LoginUserChangePWDPageState extends State<LoginUserChangePWDPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  String? currentPasswordError;
  String? newPasswordError;
  String? confirmPasswordError;

  // 스낵바 헬퍼
  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 에러 초기화
    setState(() {
      currentPasswordError = null;
      newPasswordError = null;
      confirmPasswordError = null;
    });

    // 1) 빈 입력 체크
    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        if (currentPassword.isEmpty) currentPasswordError = "현재 비밀번호를 입력해 주세요.";
        if (newPassword.isEmpty) newPasswordError = "새 비밀번호를 입력해 주세요.";
        if (confirmPassword.isEmpty) confirmPasswordError = "비밀번호 확인을 입력해 주세요.";
      });
      return;
    }

    // 2) 정책: 8자 이상
    if (newPassword.length < 8) {
      setState(() {
        newPasswordError = "8자 이상으로 설정해 주세요.";
      });
      return;
    }

    // 3) 동일 비밀번호 사용 금지
    if (newPassword == currentPassword) {
      setState(() {
        newPasswordError = "이전과 동일한 비밀번호는 사용할 수 없습니다.";
      });
      return;
    }

    // 4) 재입력 불일치
    if (newPassword != confirmPassword) {
      setState(() {
        confirmPasswordError = "새 비밀번호가 서로 일치하지 않습니다.";
      });
      return;
    }

    setState(() => isLoading = true);

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');

    if (token == null) {
      setState(() => isLoading = false);
      _show("로그인이 만료되었습니다. 다시 로그인해 주세요.");
      return;
    }

    try {
      final response = await HttpClient.patchUserUpdate(
        token: token,
        data: {
          "password": {
            "current_password": currentPassword,
            "new_password": newPassword,
          },
        },
      );

      setState(() => isLoading = false);

      if (response['success'] == true) {
        _show("비밀번호가 변경되었습니다.");
        if (!mounted) return;
        Navigator.pop(context); // 마이페이지로 돌아가기
        return;
      }

      // 실패 처리: 서버 메시지 기반 매핑
      final serverMsg = (response['message'] ?? '').toString();

      if (serverMsg.contains("현재 비밀번호가 틀립니다")) {
        setState(() {
          currentPasswordError = "현재 비밀번호가 올바르지 않습니다.";
        });
      } else if (serverMsg.contains("8자") ||
          serverMsg.contains("길이") ||
          serverMsg.contains("복잡도")) {
        // 서버가 정책 위반을 상세히 보낼 때
        setState(() {
          newPasswordError = serverMsg; // 서버 메시지 그대로 노출
        });
      } else if (serverMsg.isNotEmpty) {
        // 그 외 서버 메시지 노출(상단 스낵바)
        _show(serverMsg);
      } else {
        _show("요청을 처리할 수 없습니다. 잠시 후 다시 시도해 주세요.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      _show("네트워크 오류가 발생했습니다. 연결을 확인한 후 다시 시도해 주세요.");
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          "비밀번호 변경",
          style: TextStyle(color: Colors.black87, fontSize: 18),
        ),
        backgroundColor: const Color(0xFFFAFAFA),
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
            const Text(
              "새로운 비밀번호를 입력해 주세요",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),

            // 현재 비밀번호
            _buildPasswordField(
              controller: _currentPasswordController,
              hintText: "현재 비밀번호",
              isPasswordVisible: showCurrentPassword,
              toggleVisibility:
                  () => setState(
                    () => showCurrentPassword = !showCurrentPassword,
                  ),
              icon: Icons.verified_user_outlined,
              errorText: currentPasswordError,
            ),
            const SizedBox(height: 10),

            // 새 비밀번호
            _buildPasswordField(
              controller: _newPasswordController,
              hintText: "새 비밀번호 (8자 이상)",
              isPasswordVisible: showNewPassword,
              toggleVisibility:
                  () => setState(() => showNewPassword = !showNewPassword),
              icon: Icons.lock,
              errorText: newPasswordError,
            ),
            const SizedBox(height: 10),

            // 새 비밀번호 확인
            _buildPasswordField(
              controller: _confirmPasswordController,
              hintText: "새 비밀번호 확인",
              isPasswordVisible: showConfirmPassword,
              toggleVisibility:
                  () => setState(
                    () => showConfirmPassword = !showConfirmPassword,
                  ),
              icon: Icons.lock_person_outlined,
              errorText: confirmPasswordError,
            ),

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
                            "비밀번호 변경하기",
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

  // 공용 비밀번호 입력 필드
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isPasswordVisible,
    required VoidCallback toggleVisibility,
    required IconData icon,
    required String? errorText,
  }) {
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
              hintStyle: const TextStyle(
                color: Color(0xFFB0B0B0),
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: Colors.grey),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: toggleVisibility,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
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
