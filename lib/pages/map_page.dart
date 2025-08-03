import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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

class Hospital {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distance;


  Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,

  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'],
      name: json['facility_name'],
      address: json['road_address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      distance: json['distance_km'],

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
  String? _sido, _sigungu, _eupmyeondong;
  String _selectedMenu = ''; // '', 'shelter', 'disaster'
  Hospital? _selectedHospital;
  final List<NMarker> _hospitalMarkers = [];

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

      final userMarker = NMarker(
        id: 'user_location',
        position: userLatLng,
        icon: NOverlayImage.fromAssetImage('lib/asset/user_marker.png'),

      );
      _controller!.addOverlay(userMarker);
    }

    await _getAddress(position);
    await _fetchDisasters();
  }

  Future<void> _getAddress(Position position) async {
    final url = 'https://dapi.kakao.com/v2/local/geo/coord2address.json?x=${position.longitude}&y=${position.latitude}';
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
      }
    }
  }

  Future<void> _fetchNearbyShelters(Position position) async {
    final url = Uri.parse('http://54.253.211.96:8000/api/shelters/nearby?latitude=${position.latitude}&longitude=${position.longitude}&limit=10');
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
          icon: NOverlayImage.fromAssetImage('lib/asset/shelter_marker.png'),
          caption: NOverlayCaption(text: shelter.name),
        );
        marker.setOnTapListener((m) {
          setState(() {
            _selectedShelter =
            (_selectedShelter?.name == shelter.name) ? null : shelter;
            _showDisasterSheet = false;
          });
        });

        _shelterMarkers.add(marker);
      }

      if (_controller != null) {
        await _controller!.clearOverlays();
        await _controller!.addOverlayAll(_shelterMarkers.map((m) => m as NAddableOverlay).toSet());
        await _zoomToFitAllMarkers();
      }
    }
  }

  Future<void> _fetchDisasters() async {
    if (_sido == null || _sigungu == null || _eupmyeondong == null) return;
    final queryUri = Uri.parse('http://54.253.211.96:8000/api/disasters?sido=$_sido&sigungu=$_sigungu&eupmyeondong=$_eupmyeondong&active_only=true');
    final response = await http.get(queryUri, headers: {'accept': 'application/json'});

    if (response.statusCode == 200) {
      final jsonBody = json.decode(utf8.decode(response.bodyBytes));
      final summary = jsonBody['data'][0]['summary'] as Map<String, dynamic>;
      final total = summary.values.fold<int>(0, (sum, val) => sum + (val as int));
      final List<dynamic> data = jsonBody['data'][0]['disasters'];

      setState(() {
        _disasterList = data.map((e) => Disaster.fromJson(e)).toList();
        _hasDisasterMessage = total > 0;
        if (_selectedMenu == 'disaster') {
          _showDisasterSheet = true;
        }
      });
    }
  }

  Future<void> _fetchNearbyHospitals(Position position) async {
    final url = Uri.parse('http://54.253.211.96:8000/api/hospital/nearby?latitude=${position.latitude}&longitude=${position.longitude}&limit=10');
    final response = await http.get(url, headers: {'accept': 'application/json'});

    if (response.statusCode == 200) {
      final jsonBody = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> data = jsonBody is List ? jsonBody : jsonBody['data'];

      _hospitalMarkers.clear();

      for (var item in data) {
        final hospital = Hospital.fromJson(item);
        final marker = NMarker(
          id: 'hospital_${hospital.latitude}_${hospital.longitude}',
          position: NLatLng(hospital.latitude, hospital.longitude),
          icon: NOverlayImage.fromAssetImage('lib/asset/hospital_marker.png'),
          caption: NOverlayCaption(text: hospital.name),
        );
        marker.setOnTapListener((m) {
          setState(() {
            _selectedHospital = (_selectedHospital?.name == hospital.name) ? null : hospital;
          });
        });
        _hospitalMarkers.add(marker);
      }

      if (_controller != null) {
        await _controller!.clearOverlays();
        await _controller!.addOverlayAll(
          _hospitalMarkers.map((m) => m as NAddableOverlay).toSet(),
        ); //hospitalMarkers로 바꿈
        await _zoomToFitMarkers(_hospitalMarkers);
      }
    }
  }

  Future<void> _zoomToFitAllMarkers() async {
    if (_shelterMarkers.isEmpty || _controller == null) return;
    final bounds = _calculateBounds(_shelterMarkers.map((m) => m.position).toList());
    await _controller!.updateCamera(NCameraUpdate.fitBounds(bounds, padding: const EdgeInsets.all(80)));
  }

  Future<void> _zoomToFitMarkers(List<NMarker> markers) async {
    if (markers.isEmpty || _controller == null) return;
    final bounds = _calculateBounds(markers.map((m) => m.position).toList());
    await _controller!.updateCamera(NCameraUpdate.fitBounds(bounds, padding: const EdgeInsets.all(80)));
  }

  NLatLngBounds _calculateBounds(List<NLatLng> positions) {
    double minLat = positions.first.latitude, maxLat = positions.first.latitude;
    double minLng = positions.first.longitude, maxLng = positions.first.longitude;
    for (var p in positions) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return NLatLngBounds(southWest: NLatLng(minLat, minLng), northEast: NLatLng(maxLat, maxLng));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _buildLocationBox(),
            _buildLocationButtons(),
            _buildStatusBanner(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
                        onMapTapped: (point, latLng) {
                          setState(() {
                            _showDisasterSheet = false;
                            _selectedMenu = '';
                            _selectedHospital = null;
                            _selectedShelter = null;
                          });
                        },
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 360),
                        curve: Curves.easeOut,
                        bottom: _selectedShelter != null ? 0 : -400,
                        left: 0,
                        right: 0,
                        child: _buildShelterDetailSheet(),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 360),
                        curve: Curves.easeOut,
                        bottom: (_selectedMenu == 'disaster' && _showDisasterSheet) ? 0 : -400,
                        left: 0,
                        right: 0,
                        child: (_selectedMenu == 'disaster' && _showDisasterSheet)
                            ? _buildDisasterInfoSheet()
                            : const SizedBox.shrink(), // ✅ 조건 안 맞으면 위젯 자체 제거
                      ),

                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 360),
                        curve: Curves.easeOut,
                        bottom: _selectedHospital != null ? 0 : -400,
                        left: 0,
                        right: 0,
                        child: _buildHospitalDetailSheet(),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.black),
                                onPressed: () async {
                                  if (_controller != null) {
                                    final pos = await _controller!.getCameraPosition();
                                    final zoom = pos.zoom + 1;
                                    await _controller!.updateCamera(
                                      NCameraUpdate.fromCameraPosition(
                                        NCameraPosition(target: pos.target, zoom: zoom),
                                      ),
                                    );
                                  }
                                },
                              ),
                              Container(
                                width: 36,
                                height: 1,
                                color: Colors.grey[300], // 구분선 색상
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.black),
                                onPressed: () async {
                                  if (_controller != null) {
                                    final pos = await _controller!.getCameraPosition();
                                    final zoom = pos.zoom - 1;
                                    await _controller!.updateCamera(
                                      NCameraUpdate.fromCameraPosition(
                                        NCameraPosition(target: pos.target, zoom: zoom),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),


                    ],
                  ),

                ),
              ),

            ),

          ],
        ),

      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white, // 배경색
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // 그림자 색
              blurRadius: 10, // 퍼짐 정도
              offset: Offset(0, -2), // 위쪽으로 살짝 그림자
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0, // 내부 elevation 제거
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                break;
              case 1:
                Navigator.pushNamed(context, '/chatbot');
                break;
              case 2:
                Navigator.pushNamed(context, '/community');
                break;
              case 3:
                Navigator.pushNamed(context, '/disastermenu');
                break;
              case 4:
                Navigator.pushNamed(context, '/user');
                break;
            }
          },
          selectedItemColor: Colors.redAccent, // 선택된 아이콘 색
          unselectedItemColor: Colors.grey[300], // 비선택 아이콘 색
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedIconTheme: IconThemeData(size: 30),
          unselectedIconTheme: IconThemeData(size: 30),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.place)),
              label: '지도',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.chat)),
              label: '채팅',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.groups)),
              label: '커뮤니티',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.dashboard)),
              label: '재난메뉴',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.favorite_border)),
              label: '마이',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationBox() {
    return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child:Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 2), // 📍 아이콘 약간 오른쪽
              child: Icon(Icons.location_on, color: Colors.redAccent,size:30),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  _currentAddress ?? '주소 불러오는 중...',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,color:Colors.grey),
                ),
              ),
            ),

            IconButton(
              icon: const Icon(Icons.my_location, color: Colors.grey),
              onPressed: () async {
                await _getAndMoveToCurrentLocation();
              },
            ),
          ],
        )

    );
  }

  Widget _buildLocationButtons() {
    final List<Map<String, dynamic>> buttons = [
      {'label': '대피소', 'icon': Icons.favorite_border, 'value': 'shelter'},
      {'label': '재난정보', 'icon': Icons.warning_amber, 'value': 'disaster'},
      {'label': '병원', 'icon': Icons.local_hospital, 'value': 'hospital'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: buttons.map((b) {
          final selected = _selectedMenu == b['value'];

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    if (_selectedMenu == b['value']) {
                      // 이미 선택된 버튼 다시 누르면 → OFF
                      _selectedMenu = '';
                      _selectedHospital = null;
                      _selectedShelter = null;
                      _showDisasterSheet = false;
                    } else {
                      _selectedMenu = b['value'] as String;
                      _selectedHospital = null;
                      _selectedShelter = null; // ✅ 이 줄로 상세 시트도 OFF
                      _showDisasterSheet = (_selectedMenu == 'disaster');
                    }
                  });

                  Position pos = await Geolocator.getCurrentPosition();
                  if (_selectedMenu == 'shelter') await _fetchNearbyShelters(pos);
                  if (_selectedMenu == 'hospital') await _fetchNearbyHospitals(pos);
                  if (_selectedMenu == 'disaster') await _fetchDisasters();
                },



                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected ? Colors.red.shade400 : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? Colors.red : Colors.grey.shade300,
                      width: 1,
                    ),
                    boxShadow: [
                      if (selected)
                        const BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        )
                    ],
                  ),

                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(b['icon'] as IconData,
                            color: selected ? Colors.white : Colors.black),
                        const SizedBox(width: 6),
                        Text(
                          b['label'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: selected ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildStatusBanner() {
    String text;
    Color bgColor;

    late Icon leadingIcon;

    if (_hasDisasterMessage) {
      text = '재난 문자가 있습니다. 확인하세요';
      bgColor = Colors.redAccent;
      leadingIcon = const Icon(Icons.warning_amber_rounded, color: Colors.white,size: 22);
    } else {
      text = '재난 문자가 없습니다.';
      bgColor = Colors.green;
      leadingIcon = const Icon(Icons.check_circle_rounded, color: Colors.white,size: 22);
    }


    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          leadingIcon,
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildShelterDetailSheet() {
    if (_selectedShelter == null) return SizedBox.shrink();
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
            const Text(
              '대피소 상세 정보',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _infoRow('이름', shelter.name),
            _infoRow('주소', shelter.address),
            _infoRow('거리', '${(shelter.distance * 1000).toStringAsFixed(0)}m'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final lat = shelter.latitude;
                final lng = shelter.longitude;
                final name = Uri.encodeComponent(shelter.name);
                final url = 'nmap://route/public?dlat=$lat&dlng=$lng&dname=$name&appname=com.pan.resq';

                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('네이버지도 앱이 설치되어 있지 않습니다.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('길찾기 안내', style: TextStyle(color: Colors.white)),
            ),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size:26),
                SizedBox(width: 6),
                Text(
                  '재난정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
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

  Widget _buildHospitalDetailSheet() {
    if (_selectedHospital == null) return SizedBox.shrink();
    final hospital = _selectedHospital!;
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
            const Text('병원 상세 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _infoRow('이름', hospital.name),
            _infoRow('주소', hospital.address),
            _infoRow('거리', '${(hospital.distance * 1000).toStringAsFixed(0)}m'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final lat = hospital.latitude;
                final lng = hospital.longitude;
                final name = Uri.encodeComponent(hospital.name);
                final url = 'nmap://route/public?dlat=$lat&dlng=$lng&dname=$name&appname=com.pan.resq';

                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('네이버지도 앱이 설치되어 있지 않습니다.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('길찾기 안내', style: TextStyle(color: Colors.white)),
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

