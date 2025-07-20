import 'package:flutter/material.dart';
import 'disaster_text_only_page.dart';

class LandslidePage extends StatelessWidget {
  const LandslidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DisasterTextOnlyPage(
      title: '산사태',
      instructions: [
        '비가 많이 오면 산 주변 접근 금지',
        '흙이 무너지는 소리에 주의',
        '즉시 높은 곳으로 대피',
        '산사태 지역에서 머무르지 않기',
      ],
    );
  }
}
