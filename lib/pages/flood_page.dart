import 'package:flutter/material.dart';
import 'disaster_common_widgets.dart';

Widget buildFloodInstructions() {
  return buildDisasterInstructions(
    disasterName: '홍수',
    icon: Icons.flood_rounded,
    color:  Colors.blueGrey.shade400,
    instructions: [
      {
        'iconCode': Icons.cloud_rounded.codePoint.toString(),
        'title': '기상정보 수시 확인',
        'description': '기상청과 행정안전부 알림 등을 통해 홍수 경보, 예보 정보를 수시로 확인하세요.',
      },
      {
        'iconCode': Icons.landscape_rounded.codePoint.toString(),
        'title':'저지대 및 하천 주변 피하기',
        'description': '하천 근처, 산사태 우려 지역, 침수 위험이 있는 지하실 등은 피하세요.',
      },
      {
        'iconCode': Icons.power_off_rounded.codePoint.toString(),
        'title': '전기 차단 후 대피',
        'description': '감전 사고를 방지하기 위해 반드시 차단기를 내리고 대피하세요.',
      },
      {
        'iconCode': Icons.directions_car_filled_rounded.codePoint.toString(),
        'title': '차량 침수 시 즉시 탈출',
        'description': '물에 잠기기 시작한 차량 안에 있지 말고 즉시 문을 열고 밖으로 탈출하세요.',
      },
      {
        'iconCode': Icons.health_and_safety_rounded.codePoint.toString(),
        'title': '감염병 예방',
        'description': '침수 지역을 다녀온 후에는 손을 씻고, 오염된 음식이나 물을 피하세요.',
      },
    ],
  );
}
