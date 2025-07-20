import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'disaster_detail_page.dart';


const String kakaoRestApiKey = 'KakaoAK 6c70d9ab4ca17bdfa047539c7d8ec0a8';

class Shelter {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distance;

  Shelter({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      name: json['facility_name'],
      address: json['road_address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      distance: json['distance_km'],
    );
  }
}

class Disaster {
  final String type;
  final String info;
  final String startTime;
  final String region;
  final String disasterLevel;

  Disaster({
    required this.type,
    required this.info,
    required this.startTime,
    required this.region,
    required this.disasterLevel,
  });

  factory Disaster.fromJson(Map<String, dynamic> json) {
    return Disaster(
      type: json['disaster_type'],
      info: json['info'],
      startTime: json['start_time'],
      region: json['region_name'],
      disasterLevel: json['disaster_level'] ?? '',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(clientId: 'l66gqrjxx3');
  runApp(const MaterialApp(home: MapPage()));
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  NaverMapController? _controller;
  String? _currentAddress;
  final List<NMarker> _shelterMarkers = [];
  Shelter? _selectedShelter;
  List<Disaster> _disasterList = [];
  bool _showDisasterSheet = false;
  bool _hasDisasterMessage = false;

  String? _sido;
  String? _sigungu;
  String? _eupmyeondong;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getAndMoveToCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final userLatLng = NLatLng(position.latitude, position.longitude);

    if (_controller != null) {
      await _controller!.updateCamera(
        NCameraUpdate.fromCameraPosition(
          NCameraPosition(target: userLatLng, zoom: 15),
        ),
      );

      final marker = NMarker(
        id: 'user_location',
        position: userLatLng,
      );
      _controller!.addOverlay(marker);
    }

    await _getAddress(position);
  }

  Future<void> _getAddress(Position position) async {
    final url = 'https://dapi.kakao.com/v2/local/geo/coord2address.json'
        '?x=${position.longitude}&y=${position.latitude}';

    final response = await http.get(Uri.parse(url), headers: {'Authorization': kakaoRestApiKey});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final documents = data['documents'];
      if (documents != null && documents is List && documents.isNotEmpty) {
        final jibun = documents[0]['address']?['address_name'] ?? '';
        final road = documents[0]['road_address']?['address_name'] ?? '';
        final resultAddress = jibun.isNotEmpty ? jibun : road;

        setState(() {
          _currentAddress = resultAddress;
          _sido = documents[0]['address']?['region_1depth_name'];
          _sigungu = documents[0]['address']?['region_2depth_name'];
          _eupmyeondong = documents[0]['address']?['region_3depth_name'];
        });

        debugPrint('📍 현재 주소: $_currentAddress ($_sido $_sigungu $_eupmyeondong)');
      }
    } else {
      debugPrint('❌ 주소 요청 실패: ${response.statusCode}');
    }
  }

  Future<void> _fetchNearbyShelters(Position position) async {
    final url = Uri.parse(
      'http://54.253.211.96:8000/api/shelters/nearby'
          '?latitude=${position.latitude}&longitude=${position.longitude}&limit=10',
    );

    try {
      final response = await http.get(url, headers: {'accept': 'application/json'});

      if (response.statusCode == 200) {
        final jsonBody = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> data = jsonBody is List ? jsonBody : jsonBody['data'];

        _shelterMarkers.clear();

        for (var item in data) {
          final shelter = Shelter.fromJson(item);
          final marker = NMarker(
            id: 'shelter_${shelter.latitude}_${shelter.longitude}',
            position: NLatLng(shelter.latitude, shelter.longitude),
            caption: NOverlayCaption(text: shelter.name),
          );

          marker.setOnTapListener((NMarker m) {
            setState(() {
              _selectedShelter = (_selectedShelter?.name == shelter.name) ? null : shelter;
            });
          });

          _shelterMarkers.add(marker);
        }

        if (_controller != null) {
          await _controller!.clearOverlays();
          await _controller!.addOverlayAll(_shelterMarkers.map((m) => m as NAddableOverlay).toSet());
          await _zoomToFitAllMarkers();
        }
      } else {
        debugPrint('❌ 대피소 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 예외 발생: $e');
    }
  }

  Future<void> _zoomToFitAllMarkers() async {
    if (_shelterMarkers.isEmpty || _controller == null) return;

    final bounds = _calculateBounds(_shelterMarkers.map((m) => m.position).toList());

    await _controller!.updateCamera(
      NCameraUpdate.fitBounds(bounds, padding: EdgeInsets.all(80)),
    );
  }

  NLatLngBounds _calculateBounds(List<NLatLng> positions) {
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (var p in positions) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return NLatLngBounds(
      southWest: NLatLng(minLat, minLng),
      northEast: NLatLng(maxLat, maxLng),
    );
  }

  Future<void> _fetchDisasters() async {
    if (_sido == null || _sigungu == null || _eupmyeondong == null) {
      debugPrint('❌ 주소 정보 없음. 재난 정보를 가져올 수 없습니다.');
      return;
    }

    final queryUri = Uri.parse(
      'http://54.253.211.96:8000/api/disasters'
          '?sido=$_sido&sigungu=$_sigungu&eupmyeondong=$_eupmyeondong&active_only=true',
    );

    try {
      final response = await http.get(queryUri, headers: {'accept': 'application/json'});
      if (response.statusCode == 200) {
        final jsonBody = json.decode(utf8.decode(response.bodyBytes));

        final summary = jsonBody['data'][0]['summary'] as Map<String, dynamic>;
        final total = summary.values.fold<int>(0, (sum, val) => sum + (val as int));

        final List<dynamic> data = jsonBody['data'][0]['disasters'];

        setState(() {
          _disasterList = data.map((e) => Disaster.fromJson(e)).toList();
          _hasDisasterMessage = total > 0;
          _showDisasterSheet = true;
        });

        debugPrint("✅ 재난 정보 ${_disasterList.length}개 불러옴");
      } else {
        debugPrint('❌ 재난정보 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 재난정보 예외 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildLocationBox(),
            _buildLocationButtons(),
            _buildStatusBanner(),
            Expanded(
              child: Stack(
                children: [
                  NaverMap(
                    options: const NaverMapViewOptions(
                      mapType: NMapType.basic,
                      locationButtonEnable: false,
                      initialCameraPosition: NCameraPosition(
                        target: NLatLng(35.2313, 129.0825),
                        zoom: 12,
                      ),
                    ),
                    onMapReady: (controller) async {
                      _controller = controller;
                      await _getAndMoveToCurrentLocation();
                    },
                  ),
                  if (_selectedShelter != null) _buildShelterDetailSheet(),
                  if (_showDisasterSheet) _buildDisasterInfoSheet(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildLocationBox() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentAddress ?? '주소 불러오는 중...',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.grey),
            onPressed: () async {
              await _getAndMoveToCurrentLocation();
            },
          )
        ],
      ),
    );
  }

  Widget _buildLocationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.home_work_outlined),
              label: const Text('대피소'),
              onPressed: () async {
                setState(() {
                  _showDisasterSheet = false;
                  _selectedShelter = null;
                });
                Position pos = await Geolocator.getCurrentPosition();
                await _fetchNearbyShelters(pos);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 1,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.warning_amber_outlined),
              label: const Text('재난 정보'),
              onPressed: () async {
                setState(() {
                  _showDisasterSheet = false;
                  _selectedShelter = null;
                });
                await _fetchDisasters();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 1,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    String text;
    Color bgColor;

    if (_hasDisasterMessage) {
      text = '⚠️ 재난 문자가 있습니다. 확인하세요';
      bgColor = Colors.redAccent;
    } else {
      text = '✅ 재난 문자가 없습니다.';
      bgColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }



  Widget _buildShelterDetailSheet() {
    final shelter = _selectedShelter!;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('대피소 상세 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _infoRow('이름', shelter.name),
            _infoRow('주소', shelter.address),
            _infoRow('거리', '${(shelter.distance * 1000).toStringAsFixed(0)}m'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('길찾기 안내', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDisasterInfoSheet() {
    final grouped = <String, List<Disaster>>{};

    for (final d in _disasterList) {
      grouped.putIfAbsent(d.type, () => []).add(d);
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 340,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📢 재난정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: grouped.entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final entry = grouped.entries.elementAt(index);
                  final first = entry.value.first;

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/disasterDetail',
                        arguments: first,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  first.startTime,
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  first.region,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}


