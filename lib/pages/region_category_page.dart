import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegionCategoryPage extends StatefulWidget {
  const RegionCategoryPage({super.key});

  @override
  State<RegionCategoryPage> createState() => _RegionCategoryPageState();
}

class _RegionCategoryPageState extends State<RegionCategoryPage> {
  final storage = const FlutterSecureStorage();
  Map<int, int> notificationRegionMap =
  {}; // regionId -> notification_region_id

  final Map<int, String> regionIdToName = {
    // 서울특별시
    2: '종로구',
    95: '중구',
    178: '용산구',
    226: '성동구',
    324: '광진구',
    334: '동대문구',
    382: '중랑구',
    405: '성북구',
    486: '강북구',
    491: '도봉구',
    531: '노원구',
    556: '은평구',
    580: '서대문구',
    653: '마포구',
    695: '양천구',
    716: '강서구',
    744: '구로구',
    781: '금천구',
    785: '영등포구',
    886: '동작구',
    910: '관악구',
    948: '서초구',
    976: '강남구',
    1045: '송파구',
    1060: '강동구',

    // 부산광역시
    2560: '중구',
    2602: '서구',
    2627: '동구',
    2632: '영도구',
    2654: '부산진구',
    2666: '동래구',
    2678: '남구',
    2690: '북구',
    2704: '해운대구',
    2713: '사하구',
    2721: '금정구',
    2735: '강서구',
    2758: '연제구',
    2761: '수영구',
    2767: '사상구',
    2776: '기장군',

    // 대구광역시
    2785: '중구',
    2843: '동구',
    2890: '서구',
    2897: '남구',
    2901: '북구',
    2934: '수성구',
    2962: '달서구',
    2987: '달성군',
    3002: '군위군',

    // 인천광역시
    3012: '중구',
    3067: '동구',
    3088: '미추홀구',
    3096: '연수구',
    3103: '남동구',
    3149: '부평구',
    3163: '계양구',
    3188: '서구',
    3212: '강화군',
    3226: '옹진군',

    // 광주광역시
    3236: '동구',
    3271: '서구',
    3305: '남구',
    3336: '북구',
    3378: '광산구',

    // 대전광역시
    3482: '동구',
    3528: '중구',
    3555: '서구',
    3584: '유성구',
    3638: '대덕구',

    // 울산광역시
    3665: '중구',
    3684: '남구',
    3704: '동구',
    3714: '북구',
    3742: '울주군',

    // 세종특별자치시
    3760: '세종특별자치시',

    // 경기도
    4059: '수원시',
    4227: '성남시',
    4352: '의정부시',
    4376: '안양시',
    4411: '부천시',
    4507: '광명시',
    4530: '평택시',
    4590: '동두천시',
    4610: '안산시',
    4680: '고양시',
    4805: '과천시',
    4816: '구리시',
    4842: '남양주시',
    4867: '오산시',
    4898: '시흥시',
    4936: '군포시',
    4950: '의왕시',
    4965: '하남시',
    4995: '용인시',
    5073: '파주시',
    5111: '이천시',
    5135: '안성시',
    5181: '김포시',
    5200: '화성시',
    5258: '광주시',
    5290: '양주시',
    5313: '포천시',
    5332: '여주시',
    5519: '연천군',
    5550: '가평군',
    5560: '양평군',

    // 강원특별자치도
    12157: '춘천시',
    12197: '원주시',
    12225: '강릉시',
    12273: '동해시',
    12310: '태백시',
    12328: '속초시',
    12342: '삼척시',
    12378: '홍천군',
    12389: '횡성군',
    12399: '영월군',
    12409: '평창군',
    12418: '정선군',
    12428: '철원군',
    12440: '화천군',
    12446: '양구군',
    12452: '인제군',
    12459: '고성군',
    12466: '양양군',

    // 충청북도
    6140: '청주시',
    6356: '충주시',
    6404: '제천시',
    6469: '보은군',
    6482: '옥천군',
    6492: '영동군',
    6505: '증평군',
    6508: '진천군',
    6519: '괴산군',
    6534: '음성군',
    6568: '단양군',

    // 충청남도
    6825: '천안시',
    6926: '공주시',
    6982: '보령시',
    7029: '아산시',
    7061: '서산시',
    7089: '논산시',
    7115: '계룡시',
    7121: '당진시',
    7144: '금산군',
    7206: '부여군',
    7224: '서천군',
    7253: '청양군',
    7267: '홍성군',
    7281: '예산군',
    7319: '태안군',

    // 전북특별자치도
    12474: '전주시',
    12560: '군산시',
    12624: '익산시',
    12676: '정읍시',
    12719: '남원시',
    12759: '김제시',
    12805: '완주군',
    12819: '진안군',
    12831: '무주군',
    12838: '장수군',
    12846: '임실군',
    12859: '순창군',
    12871: '고창군',
    12885: '부안군',

    // 전라남도
    8452: '목포시',
    8548: '여수시',
    8608: '순천시',
    8663: '나주시',
    8758: '광양시',
    8776: '담양군',
    8790: '곡성군',
    8803: '구례군',
    8849: '고흥군',
    8869: '보성군',
    8882: '화순군',
    8899: '장흥군',
    8912: '강진군',
    8924: '해남군',
    8939: '영암군',
    8953: '무안군',
    8994: '함평군',
    9005: '영광군',
    9019: '장성군',
    9032: '완도군',
    9047: '진도군',
    9056: '신안군',

    // 경상북도
    9438: '신안동시',
    9493: '포항시',
    9610: '경주시',
    9679: '김천시',
    9720: '안동시',
    9785: '구미시',
    9839: '영주시',
    9875: '영천시',
    9924: '상주시',
    10002: '문경시',
    10023: '경산시',
    10094: '의성군',
    10131: '청송군',
    10142: '영양군',
    10150: '영덕군',
    10237: '청도군',
    10248: '고령군',
    10259: '성주군',
    10272: '칠곡군',
    10347: '예천군',
    10372: '봉화군',
    10384: '울진군',
    10399: '울릉군',

    // 경상남도
    10643: '창원시',
    11301: '진주시',
    11479: '통영시',
    11542: '사천시',
    11578: '김해시',
    11628: '밀양시',
    11660: '거제시',
    11685: '양산시',
    11730: '의령군',
    11746: '함안군',
    11759: '창녕군',
    11872: '고성군',
    11895: '남해군',
    11907: '하동군',
    11921: '산청군',
    11934: '함양군',
    11946: '거창군',
    11958: '합천군',

    // 제주특별자치도
    12078: '제주시',
    12126: '서귀포시',
  };

  final Map<String, List<String>> regionData = {
    '서울특별시': [
      '강남구',
      '강동구',
      '강북구',
      '강서구',
      '관악구',
      '광진구',
      '구로구',
      '금천구',
      '노원구',
      '도봉구',
      '동대문구',
      '동작구',
      '마포구',
      '서대문구',
      '서초구',
      '성동구',
      '성북구',
      '송파구',
      '영등포구',
      '양천구',
      '은평구',
      '종로구',
      '중구',
      '중랑구',
      '용산구',
    ],
    '부산광역시': [
      '강서구',
      '금정구',
      '기장군',
      '남구',
      '동구',
      '동래구',
      '부산진구',
      '북구',
      '사하구',
      '서구',
      '수영구',
      '사상구',
      '연제구',
      '영도구',
      '중구',
      '해운대구',
    ],
    '대구광역시': ['군위군', '남구', '달서구', '달성군', '동구', '북구', '서구', '수성구', '중구'],
    '인천광역시': [
      '강화군',
      '계양구',
      '남동구',
      '동구',
      '미추홀구',
      '부평구',
      '서구',
      '연수구',
      '옹진군',
      '중구',
    ],
    '광주광역시': ['광산구', '남구', '동구', '북구', '서구'],
    '대전광역시': ['대덕구', '동구', '서구', '중구', '유성구'],
    '울산광역시': ['남구', '동구', '북구', '울주군', '중구'],
    '세종특별자치시': [],
    '경기도': [
      '가평군',
      '고양시',
      '과천시',
      '광명시',
      '광주시',
      '구리시',
      '군포시',
      '김포시',
      '남양주시',
      '동두천시',
      '부천시',
      '성남시',
      '수원시',
      '시흥시',
      '안산시',
      '안성시',
      '안양시',
      '양주시',
      '양평군',
      '여주시',
      '연천군',
      '용인시',
      '오산시',
      '이천시',
      '의왕시',
      '의정부시',
      '파주시',
      '평택시',
      '포천시',
      '하남시',
      '화성시',
    ],
    '강원특별자치도': [
      '강릉시',
      '고성군',
      '동해시',
      '삼척시',
      '속초시',
      '양구군',
      '양양군',
      '원주시',
      '영월군',
      '인제군',
      '정선군',
      '철원군',
      '춘천시',
      '태백시',
      '평창군',
      '홍천군',
      '화천군',
      '횡성군',
    ],
    '충청북도': [
      '괴산군',
      '단양군',
      '보은군',
      '영동군',
      '옥천군',
      '음성군',
      '제천시',
      '증평군',
      '진천군',
      '청주시',
      '충주시',
    ],
    '충청남도': [
      '계룡시',
      '공주시',
      '금산군',
      '논산시',
      '당진시',
      '보령시',
      '부여군',
      '서산시',
      '서천군',
      '아산시',
      '예산군',
      '천안시',
      '청양군',
      '태안군',
      '홍성군',
    ],
    '전북특별자치도': [
      '고창군',
      '군산시',
      '김제시',
      '남원시',
      '무주군',
      '부안군',
      '순창군',
      '완주군',
      '익산시',
      '임실군',
      '장수군',
      '전주시',
      '정읍시',
      '진안군',
    ],
    '전라남도': [
      '강진군',
      '고흥군',
      '곡성군',
      '광양시',
      '구례군',
      '나주시',
      '담양군',
      '목포시',
      '무안군',
      '보성군',
      '순천시',
      '신안군',
      '여수시',
      '영광군',
      '영암군',
      '완도군',
      '장성군',
      '장흥군',
      '진도군',
      '함평군',
      '해남군',
      '화순군',
    ],
    '경상북도': [
      '경산시',
      '경주시',
      '고령군',
      '구미시',
      '김천시',
      '문경시',
      '봉화군',
      '상주시',
      '성주군',
      '안동시',
      '영덕군',
      '영양군',
      '영주시',
      '영천시',
      '예천군',
      '울릉군',
      '울진군',
      '의성군',
      '청도군',
      '청송군',
      '칠곡군',
      '포항시',
    ],
    '경상남도': [
      '거제시',
      '거창군',
      '고성군',
      '김해시',
      '남해군',
      '밀양시',
      '사천시',
      '산청군',
      '양산시',
      '의령군',
      '진주시',
      '창녕군',
      '창원시',
      '통영시',
      '하동군',
      '함안군',
      '함양군',
      '합천군',
    ],
    '제주특별자치도': ['서귀포시', '제주시'],
  };

  @override
  void initState() {
    super.initState();
    _fetchNotificationRegions();
  }

  Future<void> _fetchNotificationRegions() async {
    final accessToken = await storage.read(key: 'accessToken');
    if (accessToken == null) return;

    final url = Uri.parse('http://54.253.211.96:8000/api/notification-regions');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final Map<int, int> result = {
          for (var e in jsonData) e['region_id'] as int: e['id'] as int,
        };

        setState(() {
          notificationRegionMap = result;
        });
      } else {
        print('알림 지역 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('네트워크 오류: $e');
    }
  }

  Future<void> _addNotificationRegion(int regionId) async {
    final accessToken = await storage.read(key: 'accessToken');
    if (accessToken == null) return;

    final url = Uri.parse('http://54.253.211.96:8000/api/notification-regions');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'region_id': regionId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final notificationId = data['id'] as int;

        setState(() {
          notificationRegionMap[regionId] = notificationId;
        });
      } else {
        print('알림 지역 추가 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('네트워크 오류: $e');
    }
  }

  Future<void> _deleteNotificationRegion(int regionId) async {
    final accessToken = await storage.read(key: 'accessToken');
    final notificationId = notificationRegionMap[regionId];
    if (accessToken == null || notificationId == null) return;

    final url = Uri.parse(
      'http://54.253.211.96:8000/api/notification-regions/$notificationId',
    );

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        setState(() {
          notificationRegionMap.remove(regionId);
        });
      } else {
        print('알림 지역 삭제 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('네트워크 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleRegions =
    regionData.entries
        .where((e) => e.value.isNotEmpty || e.key == '세종특별자치시')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('지역 선택'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: visibleRegions.length,
          itemBuilder: (context, index) {
            final regionName = visibleRegions[index].key;
            final subCount = visibleRegions[index].value.length;
            final regionId =
                regionIdToName.entries
                    .firstWhere(
                      (e) => e.value == regionName,
                  orElse: () => const MapEntry(-1, ''),
                )
                    .key;
            final isSelected = notificationRegionMap.containsKey(regionId);

            return GestureDetector(
              onTap: () async {
                if (regionName == '세종특별자치시') {
                  if (regionId == -1) return;

                  if (isSelected) {
                    await _deleteNotificationRegion(regionId);
                  } else {
                    await _addNotificationRegion(regionId);
                  }

                  setState(() {});
                } else {
                  _showSubRegionModal(context, regionName);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color:
                  regionName == '세종특별자치시'
                      ? (isSelected ? Colors.lightBlue[100] : Colors.white)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      regionName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (subCount > 0)
                      Text(
                        '$subCount개 지역',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSubRegionModal(BuildContext context, String regionName) {
    final subRegions = regionData[regionName]!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
        builder:
            (context, setModalState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder:
              (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      regionName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  '원하는 지역을 선택해주세요',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 35,
                    runSpacing: 20,
                    children:
                    subRegions.map((sub) {
                      final matched = regionIdToName.entries
                          .firstWhere(
                            (e) => e.value == sub,
                        orElse:
                            () => const MapEntry(-1, ''),
                      );
                      final regionId = matched.key;
                      final isNotified = notificationRegionMap
                          .containsKey(regionId);

                      return GestureDetector(
                        onTap: () async {
                          if (regionId == -1) return;

                          if (isNotified) {
                            await _deleteNotificationRegion(
                              regionId,
                            );
                          } else {
                            await _addNotificationRegion(
                              regionId,
                            );
                          }
                          setModalState(() {});
                        },
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color:
                            isNotified
                                ? Colors.lightBlue[100]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              sub,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}