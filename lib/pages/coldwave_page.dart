import 'package:flutter/material.dart';
import 'disaster_common_widgets.dart';

Widget buildColdwaveInstructions() {
  return buildDisasterInstructions(
    disasterName: '한파',
    icon:Icons.ac_unit_rounded,
    color:Color(0xFF3F50B4),
    instructions: [
      {
        'iconCode': Icons.checkroom_rounded.codePoint.toString(),
        'title':'따뜻한 옷을 입고 외출 자제',
        'description': '기온이 급격히 낮아지므로 외출은 자제하고, 외출 시에는 목도리, 장갑, 모자 등을 착용해 체온을 유지하세요.',
      },
      {
        'iconCode': Icons.water_damage_rounded.codePoint.toString(),
        'title':  '수도관 동파 예방',
        'description':'수도계량기와 배관에 보온재를 감싸고, 장시간 외출 시 수돗물을 조금 틀어 놓아 동파를 방지하세요.',
      },
      {
        'iconCode': Icons.fireplace_rounded.codePoint.toString(),
        'title': '난방기기 안전 점검',
        'description': '전기장판, 온풍기, 난로 등은 과열, 누전 위험이 있으므로 주기적으로 점검하고 안전하게 사용하세요.',
      },
      {
        'iconCode':Icons.volunteer_activism_rounded.codePoint.toString(),
        'title':'노약자 및 이웃 돌보기',
        'description':  '혼자 사는 어르신, 거동이 불편한 이웃이 있는지 확인하고 필요한 도움을 주세요.',
      },
      {
        'iconCode': Icons.health_and_safety_rounded.codePoint.toString(),
        'title':  '건강관리 및 저체온증 예방',
        'description': '무리한 실외 활동을 피하고, 실내 온도는 18~20도 이상을 유지하며, 따뜻한 음식을 섭취하세요.',
      },
      {
        'iconCode': Icons.school_rounded.codePoint.toString(),
        'title': '어린이 및 학생 보호',
        'description': '화재를 방지하기 위해 전기 스위치와 가스 밸브를 차단하세요.',
      },
    ],
  );
}
