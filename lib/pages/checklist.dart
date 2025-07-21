import 'package:flutter/material.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final List<ChecklistSection> sections = [
    ChecklistSection(
      title: 'I. 손에 들고 가야 할 것 (Go Bag)',
      icon: Icons.backpack,
      items: [
        "생수 (1인당 하루 3L, 최소 3일분) ⭐",
        "간편식 (라면, 통조림, 에너지바) ⭐",
        "손전등 및 여분 건전지 ⭐",
        "상비약 (개인 복용 약물 포함)",
        "휴대용 라디오 (건전지 포함)",
        "화장지 및 물티슈",
        "우의 및 방수용품",
        "담요 또는 보온용품",
        "방독면 및 마스크",
        "귀중품 및 중요 서류 (방수 비닐 보관) ⭐",
        "예비 자동차 키와 열쇠",
        "신용카드, 현금카드 및 현금 ⭐",
        "편안한 신발 및 보온 의류",
        "가족 연락처 및 행동요령 수첩",
      ],
    ),
    ChecklistSection(
      title: 'II. 집에 비치할 것',
      icon: Icons.home,
      items: [
        "가공식품 (라면, 통조림 등 3일분)",
        "취사도구 (코펠, 버너, 부탄가스)",
        "침구 및 피복 (담요, 따뜻한 옷, 비옷)",
        "식수 저장용기 및 정수제 ⭐",
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
      title: 'III. 가정용 비상 의약품',
      icon: Icons.medical_services,
      items: [
        "소독제 (알코올, 오오드) ⭐",
        "해열진통제 (아세트아미노펜, 이부프로펜) ⭐",
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
      title: 'IV. 마을 공동 준비 사항',
      icon: Icons.groups,
      items: [
        "비상 대피 시설 (지하실, 대피소) ⭐",
        "마대 및 모래",
        "쟁이, 망토, 삽, 곡괭이",
        "사다리 및 토퍼",
        "비상 발전기 및 연료",
        "비상 통신장비",
      ],
    ),
    ChecklistSection(
      title: 'V. 화생방 방전 비상용품',
      icon: Icons.shield,
      items: [
        "방독면 또는 비닐, 수건, 마스크 ⭐",
        "보호 옷, 보호 두건 또는 비닐 옷 ⭐",
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
    checkedStates = sections
        .map((section) => List<bool>.filled(section.items.length, false))
        .toList();
  }

  double get progress {
    int total = 0;
    int completed = 0;
    for (var list in checkedStates) {
      total += list.length;
      completed += list.where((e) => e).length;
    }
    return total == 0 ? 0 : completed / total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('재난물자 체크리스트'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('비상시를 대비한 필수 물품들을 체크해보세요'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    color: Colors.indigo,
                    backgroundColor: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(progress * 100).round()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            ...List.generate(sections.length, (sectionIndex) {
              final section = sections[sectionIndex];
              return ExpansionTile(
                initiallyExpanded: true,
                backgroundColor: Colors.blue.shade50,
                title: Row(
                  children: [
                    Icon(section.icon, color: Colors.indigo),
                    const SizedBox(width: 8),
                    Text(
                      section.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
                children: List.generate(section.items.length, (itemIndex) {
                  final item = section.items[itemIndex];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        item,
                        style: TextStyle(
                          fontWeight:
                          item.contains("⭐") ? FontWeight.bold : null,
                        ),
                      ),
                      value: checkedStates[sectionIndex][itemIndex],
                      activeColor: Colors.indigo,
                      onChanged: (val) {
                        setState(() => checkedStates[sectionIndex][itemIndex] = val ?? false);
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                  );
                }),
              );
            }),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '🔷 중요 안내사항 🔷\n\n'
                    '- 별표(⭐) 표시된 항목은 최우선 준비 물품입니다\n'
                    '- 가족 구성원 수에 따라 수량을 조절하세요\n'
                    '- 장기적으로 유통기한과 상태를 점검하세요\n'
                    '- 비상시 대피 경로를 미리 확인해주세요',
              ),
            ),
          ],
        ),
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
