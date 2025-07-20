import 'package:flutter/material.dart';
import 'disaster_text_only_page.dart';

class EarthquakePage extends StatelessWidget {
  const EarthquakePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DisasterTextOnlyPage(
      title: '지진',
      instructions: [
        '탁자 밑으로 들어가 머리 보호',
        '떨어지는 물건 주의',
        '진동 멈춘 후 대피',
        '해안가에선 고지대로 대피',
      ],
    );
  }
}
