import 'package:flutter/material.dart';
import 'disaster_common_widgets.dart';

Widget buildLandslideInstructions()  {
  return buildDisasterInstructions(
    disasterName: '산사태',
    icon:Icons.terrain_rounded,
    color:Colors.brown.shade400,
    instructions: [
      {
        'iconCode': Icons.block_rounded.codePoint.toString(),
        'title':'비가 많이 오면 산 주변 접근 금지',
        'description': '산사태 위험이 높은 날에는 절대 산 주변, 비탈길, 하천 근처에 접근하지 마세요.',
      },
      {
        'iconCode': Icons.hearing_rounded.codePoint.toString(),
        'title':  '흙이 무너지는 소리에 주의',
        'description':'비 오는 날 갑작스러운 굉음이나 땅 울림, 나무 부러지는 소리가 들리면 즉시 위험을 감지하세요.',
      },
      {
        'iconCode': Icons.arrow_upward_rounded.codePoint.toString(),
        'title': '즉시 높은 곳으로 대피',
        'description': '산사태 징후가 보이면 즉시 반대 방향의 높은 지대로 신속히 이동하세요.',
      },
      {
        'iconCode':Icons.warning_amber_rounded.codePoint.toString(),
        'title':'산사태 지역에서 머무르지 않기',
        'description':  '피해 발생 지역 주변에는 추가 산사태 위험이 있으므로 머무르지 마세요.',
      },
      {
        'iconCode': Icons.phone_in_talk_rounded.codePoint.toString(),
        'title':  '긴급 신고 및 가족에게 알리기',
        'description': '119 또는 지자체에 위험 상황을 알리고, 가족이나 이웃에게도 즉시 상황을 공유하세요.',
      },
    ],
  );
}
