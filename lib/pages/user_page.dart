/*import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/api/http_client.dart';
import 'package:resq_frontend/pages/login_user_changePWD_page.dart'; // 경로를 프로젝트의 정확한 위치로 맞춰야 함
import 'package:resq_frontend/pages/change_nickname_page.dart'; // 경로 확인
import 'package:resq_frontend/pages/withdrawl_page.dart';

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChangeNicknamePage(),
      ),
    );
  }



  void _onChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginUserChangePWDPage(),
      ),
    );
  }

  void _onRegionFilterSetting() {
    Navigator.pushNamed(context, '/region-filter');
  }

  void _onTypeFilterSetting() {
    Navigator.pushNamed(context, '/type-filter');
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WithdrawalConfirmationPage(),
      ),
    );
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
                              : const AssetImage('assets/sample_profile.jpg')) as ImageProvider,
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
              _buildActionRow('지역 알림 설정', onTap: _onRegionFilterSetting),
              _buildActionRow('재난 유형 알림 설정', onTap: _onTypeFilterSetting),
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
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/map');
              break;
            case 1:
              Navigator.pushNamed(context, '/chatbot');
              break;
            case 2:
              Navigator.pushNamed(context, '/community');
              break;
            case 3:
              Navigator.pushNamed(context, '/disastermenu');
              break;
            case 4:
              break;
          }
        },
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey[300],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedIconTheme: const IconThemeData(size: 30),
        unselectedIconTheme: const IconThemeData(size: 30),
        items: const [
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.place)),
            label: '지도',
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.chat)),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.groups)),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.dashboard)),
            label: '재난메뉴',
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.favorite_border)),
            label: '마이',
          ),
        ],
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
}
*/

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/api/http_client.dart';
import '/pages/my_comments_page.dart';
import '/pages/my_posts_page.dart';

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
                setState(() => username = newNickname);
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
    );
  }

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
    );
  }

  void _onRegionFilterSetting() {
    Navigator.pushNamed(context, '/region-filter');
  }

  void _onTypeFilterSetting() {
    Navigator.pushNamed(context, '/type-filter');
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
                            child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('부산광역시 사상구', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('$username 님', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const SizedBox(height: 10),
              const Text('계정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              _buildRow('아이디', username),
              _buildRow('email', email),
              _buildActionRow('닉네임 변경', onTap: _onChangeNickname),
              _buildActionRow('비밀번호 변경', onTap: _onChangePassword),
              const SizedBox(height: 10),
              const Divider(thickness: 1),
              const SizedBox(height: 10),
              const Text('재난 문자 설정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              _buildActionRow('지역 알림 설정', onTap: _onRegionFilterSetting),
              _buildActionRow('재난 유형 알림 설정', onTap: _onTypeFilterSetting),
              const SizedBox(height: 12),
              const Divider(thickness: 1),
              const SizedBox(height: 12),
              const Text('기타', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              _buildActionRow('내가 작성한 글', onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPostsPage()));
              }),
              _buildActionRow('내가 작성한 댓글', onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyCommentsPage()));
              }),
              _buildActionRow('로그아웃', onTap: _onLogout),
              _buildActionRow('회원탈퇴', onTap: _onDeleteAccount),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
              style: const TextStyle(fontSize: 15, color: Colors.black, decoration: TextDecoration.underline),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/map');
              break;
            case 1:
              Navigator.pushNamed(context, '/chatbot');
              break;
            case 2:
              Navigator.pushNamed(context, '/community');
              break;
            case 3:
              Navigator.pushNamed(context, '/disastermenu');
              break;
            case 4:
              break;
          }
        },
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey[300],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedIconTheme: const IconThemeData(size: 30),
        unselectedIconTheme: const IconThemeData(size: 30),
        items: const [
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.place)), label: '지도'),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.chat)), label: '채팅'),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.groups)), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.dashboard)), label: '재난메뉴'),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.favorite_border)), label: '마이'),
        ],
      ),
    );
  }
}
