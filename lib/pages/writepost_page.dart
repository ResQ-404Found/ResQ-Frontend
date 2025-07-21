import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart' as parser;

class PostCreatePage extends StatefulWidget {
  const PostCreatePage({super.key});

  @override
  State<PostCreatePage> createState() => _PostCreatePageState();
}

class _PostCreatePageState extends State<PostCreatePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  String? selectedRegion;
  File? _image;

  final List<String> regions = [
    '서울',
    '부산',
    '대구',
    '인천',
    '광주',
    '대전',
    '울산',
    '세종',
    '경기',
    '강원',
    '충북',
    '충남',
    '전북',
    '전남',
    '경북',
    '경남',
    '제주',
  ];

  final Map<String, int> regionIdMap = {
    '서울': 1,
    '부산': 2559,
    '대구': 2784,
    '인천': 2011,
    '광주': 3235,
    '대전': 3481,
    '울산': 3664,
    '세종': 3759,
    '경기': 3793,
    '강원': 5660,
    '충북': 6129,
    '충남': 6580,
    '전북': 7376,
    '전남': 8143,
    '경북': 9073,
    '경남': 10404,
    '제주': 11977,
  };

  final FlutterSecureStorage storage = FlutterSecureStorage();
  String? accessToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    accessToken = await storage.read(key: 'accessToken');
    print('📦 accessToken: $accessToken'); // 디버깅 로그
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> submitPost(BuildContext context) async {
    if (accessToken == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
      return;
    }

    final uri = Uri.parse('http://54.253.211.96:8000/api/posts');
    final request =
    http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..fields['title'] = titleController.text
      ..fields['content'] = contentController.text
      ..fields['region_id'] = (regionIdMap[selectedRegion] ?? 0).toString();

    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          _image!.path,
          filename: basename(_image!.path),
          contentType: parser.MediaType('image', 'png'),
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('게시 성공: $jsonResponse');

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('게시글이 등록되었습니다.')));
        Navigator.pop(context);
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('토큰이 만료되었습니다. 다시 로그인해주세요.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        print('게시 실패: ${response.statusCode} ${response.body}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('게시 실패: 데이터를 다시 확인해주세요.')));
      }
    } catch (e) {
      print('에러 발생: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('에러 발생: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '게시글 작성',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2.0),
          child: Divider(
            height: 1,
            thickness: 3.0,
            indent: 200,
            endIndent: 200,
            color: Colors.black54,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 업로드 박스
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade300,
                child:
                _image == null
                    ? const Center(
                  child: Icon(Icons.add, size: 40, color: Colors.white),
                )
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),

            // 제목 입력
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: '제목을 입력해주세요.',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 지역 선택
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedRegion,
                  hint: const Text('지역 선택'),
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  items:
                  regions.map((region) {
                    return DropdownMenuItem(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRegion = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 내용 입력
            TextField(
              controller: contentController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: '내용',
                filled: true,
                fillColor: Color(0xFFF2F2F2),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => submitPost(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '작성 완료',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}