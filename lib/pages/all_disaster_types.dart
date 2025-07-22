import 'package:flutter/material.dart';

class AllDisasterTypeListPage extends StatelessWidget {
  final List<String> disasterTypes = [
    '화재',
    '산사태',
    '홍수',
    '지진',
    '태풍',
    '호우',
    '강풍',
    '황사',
    '해일',
    '폭염',
    '한파',
    '대설',
    '가뭄',
    '산불',
    '붕괴',
    '전기/가스 사고',
    '환경오염 사고',
    '유해물질 누출',
    '교통사고',
    '테러/전쟁/범죄',
  ];

  AllDisasterTypeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 재난정보'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: disasterTypes.length,
        itemBuilder: (context, index) {
          final type = disasterTypes[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/disastertypedetail',
                arguments: type,
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Text(
                  type,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
