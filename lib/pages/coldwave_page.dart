import 'package:flutter/material.dart';
import 'disaster_text_only_page.dart';

class ColdwavePage extends StatelessWidget {
  const ColdwavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DisasterTextOnlyPage(
      title: '한파',
      instructions: [
        '따뜻한 옷을 입고 외출 자제',
        '수도관 동파 방지',
        '난방 기기 안전 점검',
        '노약자, 이웃 돌보기',
      ],
    );
  }
}