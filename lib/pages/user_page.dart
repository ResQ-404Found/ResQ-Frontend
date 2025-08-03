import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/api/http_client.dart';
import 'login_user_changePWD_page.dart';
import 'change_nickname_page.dart';
import 'withdrawl_page.dart';
import 'my_comments_page.dart';
import 'my_posts_page.dart';

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
  int point = 2500;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final response = await HttpClient.getUserProfile(token: token);
    if (response['data'] != null) {
      final data = response['data']['data'];
      setState(() {
        username = data['username'] ?? '';
        email = data['email'] ?? '';
        profileImageUrl = data['profile_imageURL'] ?? '';
        point = data['point'] ?? 0;
      });
    } else {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final file = File(picked.path);
      setState(() {
        _profileImage = file;
      });

      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'accessToken');

      if (token != null) {
        final fileName = file.path.split('/').last;
        final imageUrl = 'https://your-cdn.com/$fileName'; 

        final response = await HttpClient.uploadProfileImage(
          token: token,
          imageFile: file,
          imageUrl: imageUrl, 
        );

        print('서버 응답: $response');

        if (response['success'] == true) {
          setState(() {
            profileImageUrl = response['image_url'] ?? '';
            _profileImage = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('업로드 실패: ${response['message']}')),
          );
        }
      }
    }
  }

  void _onChangeNickname() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangeNicknamePage()),
    );
  }

  void _onChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoginUserChangePWDPage()),
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
      MaterialPageRoute(builder: (_) => const WithdrawalConfirmationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: null,
        title: const Text(
          '마이페이지',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : (profileImageUrl.isNotEmpty
                                            ? NetworkImage(profileImageUrl)
                                            : const AssetImage(
                                              'lib/asset/sample_profile.jpg',
                                            ))
                                        as ImageProvider,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username.isNotEmpty ? '$username 님' : '회원 님',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPointCard(),
                const SizedBox(height: 24),
                const Text(
                  '계정',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                _buildSectionCard(
                  children: [
                    _buildActionRow('닉네임 변경', onTap: _onChangeNickname),
                    const Divider(
                      height: 1,
                      thickness: 0.8,
                      indent: 10,
                      endIndent: 10,
                      color: Color(0xFFF6F6F6),
                    ),
                    _buildActionRow('비밀번호 변경', onTap: _onChangePassword),
                  ],
                ),
                const Text(
                  '재난 문자 설정',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                _buildSectionCard(
                  children: [
                    _buildActionRow('지역 알림 설정', onTap: _onRegionFilterSetting),
                    const Divider(
                      height: 1,
                      thickness: 0.8,
                      indent: 10,
                      endIndent: 10,
                      color: Color(0xFFF6F6F6),
                    ),
                    _buildActionRow('재난 유형 알림 설정', onTap: _onTypeFilterSetting),
                  ],
                ),
                const Text(
                  '기타',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                _buildSectionCard(
                  children: [
                    _buildActionRow(
                      '내가 작성한 글',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyPostsPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(
                      height: 1,
                      thickness: 0.8,
                      indent: 10,
                      endIndent: 10,
                      color: Color(0xFFF6F6F6),
                    ),
                    _buildActionRow(
                      '내가 작성한 댓글',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyCommentsPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(
                      height: 1,
                      thickness: 0.8,
                      indent: 10,
                      endIndent: 10,
                      color: Color(0xFFF6F6F6),
                    ),
                    _buildActionRow('로그아웃', onTap: _onLogout),
                    const Divider(
                      height: 1,
                      thickness: 0.8,
                      indent: 10,
                      endIndent: 10,
                      color: Color(0xFFF6F6F6),
                    ),
                    _buildActionRow('회원탈퇴', onTap: _onDeleteAccount),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildPointCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.savings,
                  color: Colors.deepPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '나의 포인트',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatPoint(point)} P',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildBadge(point),
        ],
      ),
    );
  }

  Widget _buildBadge(int point) {
    String label = 'Bronze';
    Color color = Colors.brown;
    if (point >= 5000) {
      label = 'Platinum';
      color = Colors.blueGrey;
    } else if (point >= 3000) {
      label = 'Gold';
      color = Colors.amber;
    } else if (point >= 1000) {
      label = 'Silver';
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPoint(int point) {
    return point.toString().replaceAllMapped(
      RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'),
      (match) => '${match[1]},',
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionRow(String title, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
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
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedIconTheme: const IconThemeData(size: 30),
      unselectedIconTheme: const IconThemeData(size: 30),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.place), label: '지도'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),
        BottomNavigationBarItem(icon: Icon(Icons.groups), label: '커뮤니티'),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '재난메뉴'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: '마이'),
      ],
    );
  }
}
