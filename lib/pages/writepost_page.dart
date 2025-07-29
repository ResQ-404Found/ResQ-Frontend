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
  String? selectedPostType;
  File? _image;

  final List<String> regions = [
    '서울', '부산', '대구', '인천', '광주', '대전', '울산', '세종',
    '경기', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주',
  ];

  final List<String> postTypes = ['재난 게시글', '잡담 게시글'];

  final Map<String, int> regionIdMap = {
    '서울': 1, '부산': 2559, '대구': 2784, '인천': 2011, '광주': 3235,
    '대전': 3481, '울산': 3664, '세종': 3759, '경기': 3793, '강원': 5660,
    '충북': 6129, '충남': 6580, '전북': 7376, '전남': 8143,
    '경북': 9073, '경남': 10404, '제주': 11977,
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
    print('📦 accessToken: $accessToken');
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    final uri = Uri.parse('http://54.253.211.96:8000/api/posts');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..fields['title'] = titleController.text
      ..fields['content'] = contentController.text
      ..fields['region_id'] = (regionIdMap[selectedRegion] ?? 0).toString()
      ..fields['type'] = selectedPostType == '재난 게시글' ? 'disaster' : 'normal';

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
        final Map<String, dynamic> createdPost = Map<String, dynamic>.from(jsonResponse);

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/allpostdetail',
          ModalRoute.withName('/community'),
          arguments: createdPost,
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('토큰이 만료되었습니다. 다시 로그인해주세요.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시 실패: 데이터를 다시 확인해주세요.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: $e')),
      );
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
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '게시글 작성',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2.0),
          child: Divider(
            thickness: 2.5,
            indent: 150,
            endIndent: 150,
            color: Colors.black45,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 업로드
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _image == null
                    ? const Center(
                  child: Icon(Icons.add_a_photo, size: 36, color: Colors.white),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 제목 입력
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: '제목을 입력해주세요.',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // 게시판 선택
            _buildDropdown('게시판 선택', postTypes, selectedPostType, (val) {
              setState(() {
                selectedPostType = val;
              });
            }),

            const SizedBox(height: 14),

            // 지역 선택
            _buildDropdown('지역 선택', regions, selectedRegion, (val) {
              setState(() {
                selectedRegion = val;
              });
            }),

            const SizedBox(height: 20),

            // 내용 입력
            TextField(
              controller: contentController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: '내용을 입력하세요',
                contentPadding: const EdgeInsets.all(16),
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),

            // 작성 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => submitPost(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // 드롭다운 공통 위젯
  Widget _buildDropdown(String hint, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(hint),
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
