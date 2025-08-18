import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui'; // ImageFilter.blur 사용


class Donation {
  final int id;
  final String title;
  final String sponsorName;
  final String disasterType;
  final String content;
  final String startDate;
  final String dueDate;
  final int targetMoney;
  final int currentMoney;
  final String imageUrl;

  Donation({
    required this.id,
    required this.title,
    required this.sponsorName,
    required this.disasterType,
    required this.content,
    required this.startDate,
    required this.dueDate,
    required this.targetMoney,
    required this.currentMoney,
    required this.imageUrl,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      sponsorName: json['sponsor_name'] ?? '',
      disasterType: json['disaster_type'] ?? '',
      content: json['content'] ?? '',
      startDate: json['start_date'] ?? '',
      dueDate: json['due_date'] ?? '',
      targetMoney: json['target_money'] ?? 0,
      currentMoney: json['current_money'] ?? 0,
      imageUrl: json['image_url'] ?? '',
    );
  }

  double get progress => currentMoney / (targetMoney == 0 ? 1 : targetMoney);
}

class BannerItem {
  final String imageUrl;
  final String linkUrl;
  final String title;
  final String? subtitle;
  final double blur;

  BannerItem(
      this.imageUrl,
      this.linkUrl, {
        required this.title,
        this.subtitle,
        this.blur = 1.5,
      });
}


class DonationListPage extends StatefulWidget {
  const DonationListPage({super.key});

  @override
  State<DonationListPage> createState() => _DonationListPageState();
}

class _DonationListPageState extends State<DonationListPage> {
  final List<BannerItem> _banners = [
    BannerItem(
      'https://m.worldvision.or.kr/story/wp-content/uploads/2019/12/result_191224_thumb-759x500.jpg',
      'https://habitat.or.kr/landing/2024/119hada/',
      title: '수해 지역 긴급 구호',
      subtitle: '지금 도움이 필요해요',
      blur: 1.8,
    ),
    BannerItem(
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRGox6FNylK1TEefQXcgEiHxfQxCdyh1b1QqyDY2K_3g0R6S94TQroeeJ9s76tOphm7PTA&usqp=CAU',
      'https://habitat.or.kr/landing/2024/119hada/',
      title: '산불 피해 복구 지원',
      subtitle: '작은 손길이 큰 힘이 됩니다',
      blur: 1.2,
    ),
    BannerItem(
      'https://my.worldvision.or.kr/uploads/campaign/sponsorBg/20250326/20250326104928_Wildfire-EmergencyRelief-1236X480.jpg',
      'https://habitat.or.kr/landing/2024/119hada/',
      title: '지진 피해 이재민 돕기',
      subtitle: '긴급 생필품 전달',
      blur: 1.6,
    ),
  ];
  final PageController _pageController = PageController();
  int _currentBanner = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<List<Donation>> fetchDonations() async {
    final response = await http.get(
      Uri.parse('http://54.253.211.96:8000/api/sponsor'),
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => Donation.fromJson(e)).toList();
    } else {
      throw Exception('후원 목록 불러오기 실패');
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없어요.')),
      );
    }
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 7,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _banners.length,
                    onPageChanged: (i) => setState(() => _currentBanner = i),
                    itemBuilder: (_, i) {
                      final item = _banners[i];
                      return InkWell(
                        onTap: () => _openLink(item.linkUrl),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // 이미지 + 블러
                            ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: item.blur,
                                sigmaY: item.blur,
                              ),
                              child: Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                // 약간 어둡게 블렌딩하면 텍스트 가독성↑
                                color: Colors.black.withOpacity(0.18),
                                colorBlendMode: BlendMode.darken,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[200],
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            // 하단 그라디언트
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.center,
                                  colors: [
                                    Colors.black.withOpacity(0.45),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            // 중앙 텍스트(배너마다 다름)
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 28,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  if (item.subtitle != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      item.subtitle!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.95),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 점 인디케이터
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _banners.length,
                  (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentBanner == i ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentBanner == i
                      ? Colors.redAccent
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _donationCard(Donation d) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/detail', arguments: d),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              d.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          d.disasterType,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '~ ${d.dueDate}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    d.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    d.sponsorName,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${d.currentMoney ~/ 10000}만원',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.blue,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '목표 ${d.targetMoney ~/ 10000}만원',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: d.progress,
                      backgroundColor: Colors.grey[300],
                      color: Colors.redAccent,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(d.progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/detail', arguments: d),
                      child: const Text(
                        '후원하기',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.chevron_left, size: 35),
          onPressed: () => Navigator.pop(context),
        )
            : null,
        title: const Text('후원 목록', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: FutureBuilder<List<Donation>>(
        future: fetchDonations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('에러: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildBanner()),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: Text('등록된 후원 정보가 없습니다.')),
                  ),
                ),
              ],
            );
          }

          final donations = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildBanner()),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _donationCard(donations[index]),
                  childCount: donations.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),
    );
  }
}
