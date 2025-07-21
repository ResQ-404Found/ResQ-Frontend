import 'package:flutter/material.dart';
import 'disaster_common_widgets.dart';

Widget buildTyphoonInstructions()  {
  return buildDisasterInstructions(
    disasterName: '태풍',
    icon:Icons.air_rounded,
    color:Colors.teal.shade400,
    instructions: [
      {
        'iconCode': Icons.window_rounded.codePoint.toString(),
        'title':'창문, 출입문 단단히 고정',
        'description': '강풍에 대비해 창문과 출입문을 테이프나 못 등으로 단단히 고정하고, 유리 파편 방지를 위해 커튼을 쳐두세요.',
      },
      {
        'iconCode': Icons.home_rounded.codePoint.toString(),
        'title':  '외출 삼가, 실내 대피',
        'description':'태풍 경보 시에는 외출을 삼가고 실내에서 대피 장소를 미리 확인하세요.',
      },
      {
        'iconCode': Icons.block_flipped.codePoint.toString(),
        'title': '침수지역 접근 금지',
        'description':'하천, 해안도로, 지하차도 등 침수 위험 지역은 절대 접근하지 마세요.',
      },
      {
        'iconCode':Icons.wifi_tethering_rounded.codePoint.toString(),
        'title':'기상정보 수시 확인',
        'description': '기상청, 재난알림 앱 등을 통해 태풍의 이동 경로와 속도를 실시간으로 확인하세요.',
      },
      {
        'iconCode': Icons.power_settings_new_rounded.codePoint.toString(),
        'title':  '전기 및 가스 점검',
        'description': '정전이나 누전 위험을 방지하기 위해 가전제품 플러그를 뽑고 가스 밸브를 점검하세요.',
      },
    ],
  );
}
