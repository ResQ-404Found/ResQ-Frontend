import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/api/http_client.dart';

class ChangeNicknamePage extends StatefulWidget {
  const ChangeNicknamePage({super.key});

  @override
  State<ChangeNicknamePage> createState() => _ChangeNicknamePageState();
}

class _ChangeNicknamePageState extends State<ChangeNicknamePage> {
  final TextEditingController _nicknameController = TextEditingController();
  bool isLoading = false;

  Future<void> updateNickname() async {
    final newNickname = _nicknameController.text.trim();

    if (newNickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("닉네임을 입력하세요.")),
      );
      return;
    }

    setState(() => isLoading = true);

    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');

    if (token == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인이 필요합니다.")),
      );
      return;
    }

    final response = await HttpClient.patchUserUpdate(
      token: token,
      data: {"username": newNickname},
    );

    setState(() => isLoading = false);

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("닉네임이 변경되었습니다.")),
      );
      Navigator.pop(context);  // 닉네임 변경 후 뒤로 가기
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? '닉네임 변경 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text("닉네임 변경", style: TextStyle(color: Colors.black87, fontSize: 18)),
        backgroundColor: Color(0xFFFAFAFA),
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
              "새 닉네임을 입력하세요",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),

            // 닉네임 입력 박스
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
                controller: _nicknameController,
                decoration: InputDecoration(
                  hintText: "새 닉네임을 입력하세요",
                  hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
                  prefixIcon: const Icon(Icons.edit, color: Colors.grey),  // 아이콘 추가
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: 240,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateNickname,
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
                    "닉네임 변경하기",
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
}
