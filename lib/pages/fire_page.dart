import 'package:flutter/material.dart';
import 'disaster_common_widgets.dart';

/// 화재 전용 행동요령 구성
Widget buildFireInstructions() {
  return buildDisasterInstructions(
    disasterName: '화재',
    icon: Icons.local_fire_department_rounded,
    color: Colors.red,
    instructions: [
      {
        'iconCode': Icons.campaign_rounded.codePoint.toString(),
        'title': '“불이야!”라고 외친다',
        'description': '주변 사람들에게 위험을 알리고 신속히 대피할 수 있도록 소리쳐서 알리세요.',
      },
      {
        'iconCode': Icons.masks_rounded.codePoint.toString(),
        'title': '젖은 수건으로 코와 입을 막는다',
        'description': '연기 흡입을 방지하기 위해 젖은 수건이나 옷으로 코와 입을 막아 호흡을 최소화하세요.',
      },
      {
        'iconCode': Icons.arrow_downward_rounded.codePoint.toString(),
        'title': '낮은 자세로 이동한다',
        'description': '연기는 위로 올라가기 때문에 바닥에 최대한 낮게 몸을 숙여 이동하세요.',
      },
      {
        'iconCode': Icons.exit_to_app_rounded.codePoint.toString(),
        'title': '건물 밖으로 신속히 대피한다',
        'description': '비상구나 계단을 이용하여 엘리베이터가 아닌 계단으로 대피하세요.',
      },
      {
        'iconCode': Icons.call_rounded.codePoint.toString(),
        'title': '119에 신고한다',
        'description': '안전한 장소로 이동 후, 119에 화재 사실과 위치를 신속히 신고하세요.',
      },
    ],
  );
}
