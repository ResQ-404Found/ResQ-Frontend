import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 프로필 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/pear.jpg'), // 이미지 추가 필요
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.camera_alt, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '부산광역시 사상구',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '찰보리빵조아 님',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),

            // 계정
            _sectionTitle('계정'),
            _infoRow('아이디', 'djhdpfjdkl'),
            _infoRow('email', 'djhdpfjdkl.com'),
            _clickableRow('닉네임 변경'),
            _clickableRow('비밀번호 변경'),

            const Divider(),

            // 커뮤니티
            _sectionTitle('커뮤니티'),
            _clickableRow('작성 글 내역'),
            _clickableRow('작성 댓글 내역'),

            const Divider(),

            // 기타
            _sectionTitle('기타'),
            _clickableRow('로그아웃'),
            _clickableRow('회원탈퇴'),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // 하단 네비게이션 바
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
                onPressed: () {
                  // 홈으로 이동
                },
              ),
              IconButton(
                icon: Icon(Icons.feed, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () {
                  // 피드로 이동
                },
              ),
              IconButton(
                icon: Icon(Icons.groups, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () {
                  // 커뮤니티로 이동
                },
              ),
              IconButton(
                icon: Icon(Icons.emergency_share, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () {
                  // 재난정보로 이동
                },
              ),
              IconButton(
                icon: Icon(Icons.person, color: Colors.grey[400]),
                iconSize: 32,
                onPressed: () {
                  // 마이페이지로 이동 (현재 페이지)
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 섹션 타이틀 위젯
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // 정보 표시 줄 (아이디, 이메일 등)
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(title)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // 클릭 가능한 회색 텍스트 항목
  Widget _clickableRow(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
