import 'package:flutter/material.dart';
import 'disaster_text_only_page.dart';

class TyphoonPage extends StatelessWidget {
  const TyphoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DisasterTextOnlyPage(
      title: '태풍',
      instructions: [
        '창문, 출입문 단단히 고정',
        '외출 삼가, 실내 대피',
        '침수지역 접근 금지',
        '기상정보 수시 확인',
      ],
    );
  }
}
