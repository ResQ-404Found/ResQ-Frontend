import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  NaverMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildLocationBox(),
            _buildLocationButtons(),
            _buildStatusBanner(),
            Expanded(
              child: NaverMap(
                onMapReady: (controller) {
                  _mapController = controller;
                  debugPrint("Naver Map is ready!");
                },
                options: const NaverMapViewOptions(
                  mapType: NMapType.basic,
                  initialCameraPosition: NCameraPosition(
                    target: NLatLng(35.2313, 129.0825), // Pusan National University
                    zoom: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildLocationBox() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.black87),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("부산",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 2),
              Text('부산 대학교63번길 ··',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.favorite_border),
              label: const Text('대피소'),
              onPressed: () {
                // TODO: Add your logic here
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Colors.black12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.info_outline),
              label: const Text('재난 정보'),
              onPressed: () {
                // TODO: Add your logic here
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Colors.black12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        '인전 구역 입니다.',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final icons = [
      Icons.home,
      Icons.feed,
      Icons.groups,
      Icons.emergency_share,
      Icons.person,
    ];

    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(icons.length, (index) {
            return IconButton(
              icon: Icon(
                icons[index],
                color: _currentIndex == index ? Colors.black87 : Colors.grey[400],
              ),
              iconSize: 32,
              onPressed: () {
                setState(() {
                  _currentIndex = index;
                });
                // TODO: Add navigation or page switching logic if needed
              },
            );
          }),
        ),
      ),
    );
  }
}
