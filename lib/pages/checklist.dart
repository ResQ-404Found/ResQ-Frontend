import 'package:flutter/material.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final List<ChecklistSection> sections = [
    ChecklistSection(
      title: '가방에 챙길 것',
      icon: Icons.backpack,
      items: [
        "⭐ 생수 (1인당 하루 3L, 최소 3일분)",
        "⭐ 간편식 (라면, 통조림, 에너지바)",
        "⭐ 손전등 및 여분 건전지",
        "⭐ 귀중품 및 중요 서류 (방수 비닐 보관)",
        "⭐ 신용카드, 현금카드 및 현금",
        "상비약 (개인 복용 약물 포함)",
        "휴대용 라디오 (건전지 포함)",
        "화장지 및 물티슈",
        "우의 및 방수용품",
        "담요 또는 보온용품",
        "방독면 및 마스크",
        "예비 자동차 키와 열쇠",

        "편안한 신발 및 보온 의류",
        "가족 연락처 및 행동요령 수첩",
      ],
    ),
    ChecklistSection(
      title: '집에 비치할 것',
      icon: Icons.home,
      items: [
        "⭐ 식수 저장용기 및 정수제 ",
        "가공식품 (라면, 통조림 등 3일분)",
        "취사도구 (코펠, 버너, 부탄가스)",
        "침구 및 피복 (담요, 따뜻한 옷, 비옷)",
        "개인위생용품 (비누, 치약, 칫솔, 수건)",
        "라디오, 휴대폰 충전기, 배터리",
        "전등, 양초, 성냥 (라이터)",
        "다용도 칼, 로프, 테이프",
        "소화기 및 화재 대비용품",
        "여성 위생용품",
        "장갑, 안전모, 보호안경",
      ],
    ),
    ChecklistSection(
      title: '가정용 비상 의약품',
      icon: Icons.medical_services,
      items: [
        "⭐ 소독제 (알코올, 오오드) ",
        "⭐ 해열진통제 (아세트아미노펜, 이부프로펜) ",
        "소화제 및 지사제",
        "화상연고 및 상처치료제",
        "지혈제 및 소염제",
        "핀셋 및 의료용 가위",
        "붕대 및 탄력붕대",
        "탈지면 및 거즈",
        "반창고 (다양한 크기)",
        "삼각건 및 의료용 테이프",
        "체온계 및 혈압계",
      ],
    ),
    ChecklistSection(
      title: '마을 공동 준비 사항',
      icon: Icons.groups,
      items: [
        "⭐ 비상 대피 시설 (지하실, 대피소)",
        "마대 및 모래",
        "쟁이, 망토, 삽, 곡괭이",
        "사다리 및 토퍼",
        "비상 발전기 및 연료",
        "비상 통신장비",
      ],
    ),
    ChecklistSection(
      title: '화생방 방전 비상용품',
      icon: Icons.shield,
      items: [
        "⭐ 방독면 또는 비닐, 수건, 마스크",
        "⭐ 보호 옷, 보호 두건 또는 비닐 옷",
        "방독(고무) 장화",
        "방독(고무) 장갑",
        "제독제 및 세정용품",
        "밀폐형 비닐봉지",
      ],
    ),
  ];

  late List<List<bool>> checkedStates;

  @override
  void initState() {
    super.initState();
    checkedStates = sections.map((s) => List.filled(s.items.length, false)).toList();
  }

  @override
  Widget build(BuildContext context) {
    int total = 0, done = 0;
    for (int i = 0; i < checkedStates.length; i++) {
      total += checkedStates[i].length;
      done += checkedStates[i].where((e) => e).length;
    }
    final double percent = total == 0 ? 0.0 : done / total;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('재난 대비 체크리스트'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _buildOverallProgress(percent, done, total),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: sections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, sectionIndex) {
                  final section = sections[sectionIndex];
                  final sectionDone = checkedStates[sectionIndex].where((e) => e).length;
                  final sectionTotal = section.items.length;
                  final sectionPercent = sectionTotal == 0 ? 0 : (sectionDone / sectionTotal);
                  final isSectionCompleted = sectionDone == sectionTotal;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:  Color(0x54BFBFBF),
                        width: 1.5,
                      ),

                      // 빨간 테두리 추가
                    ),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 12.0), // 왼쪽 8, 오른쪽 12 간격 추가
                                child: CircleAvatar(
                                  backgroundColor: section.title.contains('가방') ? Colors.redAccent :
                                  section.title.contains('집') ? Colors.orangeAccent :
                                  section.title.contains('의약품') ? Colors.green :
                                  section.title.contains('마을') ? Colors.blueAccent :
                                  section.title.contains('화생방') ? Colors.deepPurple :
                                  Colors.indigo,
                                  child: Icon(section.icon, color: Colors.white),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(section.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('$sectionDone/$sectionTotal 완료 (${(sectionPercent * 100).round()}%)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Text('${(sectionPercent * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Padding(
                          padding: const EdgeInsets.only(left: 56),
                          child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                          value: sectionPercent.toDouble(),
                          minHeight: 6,
                              color: section.title.contains('가방') ? Colors.redAccent :
                              section.title.contains('집') ? Colors.orangeAccent :
                              section.title.contains('의약품') ? Colors.green :
                              section.title.contains('마을') ? Colors.blueAccent :
                              section.title.contains('화생방') ? Colors.deepPurple :
                              Colors.indigo,
                              backgroundColor: Colors.grey.shade300,
                            ),
                          ),
                          ),
                        ],
                      ),


                      children: List.generate(section.items.length, (itemIndex) {
                        final item = section.items[itemIndex];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: checkedStates[sectionIndex][itemIndex]
                                ? Colors.grey.shade100   // 체크되면 연한 회색 배경
                                : Colors.white,          // 체크 안 됐으면 흰색
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: checkedStates[sectionIndex][itemIndex]
                                  ?  Color(0xAAAAAA)
                                  :  Color(0x54BFBFBF) ,
                              width: 1.5,
                            ),
                          ),
                          child: CheckboxListTile(
                            title: Text(
                              item,
                              style: TextStyle(
                                decoration: checkedStates[sectionIndex][itemIndex]
                                    ? TextDecoration.lineThrough  // 체크되면 줄긋기
                                    : TextDecoration.none,
                              ),
                            ),
                            value: checkedStates[sectionIndex][itemIndex],
                            activeColor: Color(0xFFFF4242),  // 체크 시 빨간색
                            checkColor: Colors.white,       // 체크한 아이콘 색상
                            onChanged: (val) {
                              setState(() => checkedStates[sectionIndex][itemIndex] = val ?? false);
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgress(double progress, int completed, int total) {
    final percent = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,  // 박스 안은 흰색
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.5),  // 빨간색 그림자
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 13), // 진행 바 오른쪽으로 이동
                child: Stack(
                  alignment: Alignment.center,  // Stack 내의 요소들이 겹치지 않도록 중앙 정렬
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                      ),
                    ),
                    // 원형 안에 텍스트 추가
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                        const Text(
                          '완료',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),  // 텍스트 오른쪽으로 이동
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '전체 진행률',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$completed / $total 완료',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }







}

class ChecklistSection {
  final String title;
  final IconData icon;
  final List<String> items;

  ChecklistSection({required this.title, required this.icon, required this.items});
}
