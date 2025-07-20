import 'package:flutter/material.dart';
import 'disaster_text_only_page.dart';

class FloodPage extends StatelessWidget {
  const FloodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DisasterTextOnlyPage(
      title: '홍수',
      instructions: [
        '기상정보 수시 확인',
        '저지대, 하천 주변 피하기',
        '전기 차단 후 대피',
        '차량이 침수되면 즉시 탈출',
      ],
    );
  }
}
