import 'package:flutter/material.dart';
import 'disaster_text_only_page.dart';

class FirePage extends StatelessWidget {
  const FirePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DisasterTextOnlyPage(
      title: '화재',
      instructions: [
        '"불이야!"라고 외친다',
        '젖은 수건으로 코와 입을 막는다',
        '낮은 자세로 이동한다',
        '건물 밖으로 신속히 대피한다',
      ],
    );
  }
}
