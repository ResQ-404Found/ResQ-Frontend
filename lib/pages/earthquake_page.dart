import 'package:flutter/material.dart';
import 'disaster_common_widgets.dart';

Widget buildEarthquakeInstructions() {
  return buildDisasterInstructions(
    disasterName: '지진',
    icon: Icons.warning_amber_rounded,
    color: Colors.orange.shade500,
    instructions: [
      {
        'iconCode': Icons.table_bar_rounded.codePoint.toString(),
        'title': '탁자 밑으로 들어가 머리 보호',
        'description':  '진동이 시작되면 단단한 탁자 밑으로 들어가 두 손으로 머리와 목을 감싸고 보호하세요.',
      },
      {
        'iconCode': Icons.chair_alt_rounded.codePoint.toString(),
        'title': '떨어지는 물건 주의',
        'description': '진동 중에는 유리, 액자, 천장등, 가전제품 등 떨어질 수 있는 물건에서 떨어지세요.',
      },
      {
        'iconCode': Icons.directions_run_rounded.codePoint.toString(),
        'title':  '진동 멈춘 후 대피',
        'description': '지진이 멈춘 후 침착하게 출입문을 열고, 계단을 이용해 밖으로 대피하세요. 엘리베이터는 절대 금지!',
      },
      {
        'iconCode':Icons.waves_rounded.codePoint.toString(),
        'title':'해안가에서는 고지대로 대피',
        'description': '해안 근처에 있다면 즉시 높은 지대로 이동하세요. 지진 후 쓰나미가 발생할 수 있습니다.',
      },
      {
        'iconCode': Icons.lightbulb_rounded.codePoint.toString(),
        'title': '전기·가스 차단',
        'description': '화재를 방지하기 위해 전기 스위치와 가스 밸브를 차단하세요.',
      },
    ],
  );
}
