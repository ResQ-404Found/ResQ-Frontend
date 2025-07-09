import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/api/http_client.dart'; // getUserProfile 메서드가 정의되어 있어야 함

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  File? _profileImage;
  String username = '';
  String email = '';
  String profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');

    if (token == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    final response = await HttpClient.getUserProfile(token: token);

    if (response['data'] != null) {
      setState(() {
        username = response['data']['username'];
        email = response['data']['email'];
        profileImageUrl = response['data']['profile_imageURL'];
      });
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  void _onChangeNickname() {
  final TextEditingController nicknameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('닉네임 변경'),
      content: TextField(
        controller: nicknameController,
        decoration: const InputDecoration(
          hintText: '새 닉네임 입력',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () async {
            String newNickname = nicknameController.text.trim();
            if (newNickname.isEmpty) return;

            const storage = FlutterSecureStorage();
            final token = await storage.read(key: 'accessToken');

            if (token == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그인이 필요합니다')),
              );
              return;
            }

            final response = await HttpClient.patchUserUpdate(
              token: token,
              data: {"username": newNickname},
            );

            Navigator.pop(context);

            if (response['success']) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('닉네임이 변경되었습니다')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(response['message'] ?? '닉네임 변경 실패')),
              );
            }
          },
          child: const Text('확인'),
        ),
      ],
    ),
  );  }

  void _onChangePassword() {
final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('비밀번호 변경'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: currentController,
            obscureText: true,
            decoration: const InputDecoration(labelText: '현재 비밀번호'),
          ),
          TextField(
            controller: newController,
            obscureText: true,
            decoration: const InputDecoration(labelText: '새 비밀번호'),
          ),
          TextField(
            controller: confirmController,
            obscureText: true,
            decoration: const InputDecoration(labelText: '새 비밀번호 확인'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () async {
            final current = currentController.text;
            final newPass = newController.text;
            final confirm = confirmController.text;

            if (newPass != confirm) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('새 비밀번호가 일치하지 않습니다')),
              );
              return;
            }

            const storage = FlutterSecureStorage();
            final token = await storage.read(key: 'accessToken');

            if (token == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그인이 필요합니다')),
              );
              return;
            }

            final response = await HttpClient.patchUserUpdate(
              token: token,
              data: {
                "password": {
                  "current_password": current,
                  "new_password": newPass,
                }
              },
            );

            Navigator.pop(context);

            if (response['success']) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('비밀번호가 변경되었습니다')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(response['message'] ?? '비밀번호 변경 실패')),
              );
            }
          },
          child: const Text('변경'),
        ),
      ],
    ),
  );  }

  void _onFilterSetting() {
    print('재난 문자 필터링 설정 클릭됨');
  }

  void _onLogout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _onDeleteAccount() {
    Navigator.pushNamed(context, '/withdraw');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '마이페이지',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : (profileImageUrl.isNotEmpty
                                  ? NetworkImage(profileImageUrl)
                                  : const AssetImage('assets/sample_profile.jpg'))
                                  as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '부산광역시 사상구',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$username 님',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const SizedBox(height: 10),
              const Text(
                '계정',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              _buildRow('아이디', username),
              _buildRow('email', email),
              _buildActionRow('닉네임 변경', onTap: _onChangeNickname),
              _buildActionRow('비밀번호 변경', onTap: _onChangePassword),
              const SizedBox(height: 10),
              const Divider(thickness: 1),
              const SizedBox(height: 10),
              const Text(
                '재난 문자 설정',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              _buildToggleRow('재난 문자 필터링 여부', true),
              _buildActionRow('재난 문자 필터링 설정', onTap: _onFilterSetting),
              const SizedBox(height: 12),
              const Divider(thickness: 1),
              const SizedBox(height: 12),
              const Text(
                '기타',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              _buildActionRow('로그아웃', onTap: _onLogout),
              _buildActionRow('회원탈퇴', onTap: _onDeleteAccount),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () => Navigator.pushNamed(context, '/map'),
              ),
              IconButton(
                icon: Icon(Icons.chat, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () => Navigator.pushNamed(context, '/allposts'),
              ),
              IconButton(
                icon: Icon(Icons.groups, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () => Navigator.pushNamed(context, '/community'),
              ),
              IconButton(
                icon: Icon(Icons.emergency_share, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () => Navigator.pushNamed(context, '/disastermenu'),
              ),
              IconButton(
                icon: const Icon(Icons.person),
                iconSize: 32,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15)),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildActionRow(String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, bool initialValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15)),
          Switch(
            value: initialValue,
            onChanged: (value) {},
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
