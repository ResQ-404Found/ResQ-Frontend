import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class PostEditPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostEditPage({super.key, required this.post});

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  String? selectedRegion;
  File? _image;
  int? postId;
  final storage = FlutterSecureStorage();

  final List<String> regions = [
    '서울', '부산', '대구', '인천', '광주', '대전', '울산', '세종',
    '경기', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주',
  ];

  final Map<String, int> regionIdMap = {
    '서울': 1, '부산': 2559, '대구': 2784, '인천': 2011, '광주': 3235,
    '대전': 3481, '울산': 3664, '세종': 3759, '경기': 3793, '강원': 5660,
    '충북': 6129, '충남': 6580, '전북': 7376, '전남': 8143,
    '경북': 9073, '경남': 10404, '제주': 11977,
  };

  @override
  void initState() {
    super.initState();
    final post = widget.post;
    postId = post['id'];
    titleController.text = post['title'] ?? '';
    contentController.text = post['content'] ?? '';
    selectedRegion = regionIdMap.entries
        .firstWhere((e) => e.value == post['region_id'], orElse: () => const MapEntry('부산', 2559))
        .key;
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

  Future<void> _submitEdit(BuildContext context) async {
    if (postId == null) return;
    final token = await storage.read(key: 'accessToken');

    final uri = Uri.parse('http://54.253.211.96:8000/api/posts/$postId');
    final request = http.MultipartRequest('PATCH', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['title'] = titleController.text
      ..fields['content'] = contentController.text
      ..fields['region_id'] = (regionIdMap[selectedRegion] ?? 0).toString();

    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          _image!.path,
          filename: basename(_image!.path),
          contentType: MediaType('image', 'png'),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final updatedPost = jsonDecode(response.body);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/postDetail',
        arguments: updatedPost,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정 실패: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(title: const Text('게시글 수정'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade300,
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : (post['post_imageURLs'] != null && post['post_imageURLs'].isNotEmpty)
                    ? Image.network(post['post_imageURLs'][0])
                    : const Icon(Icons.add, size: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: '제목을 입력해주세요.',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedRegion,
                  isExpanded: true,
                  hint: const Text('지역 선택'),
                  items: regions.map((region) {
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
            TextField(
              controller: contentController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: '내용을 입력해주세요',
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
                onPressed: () => _submitEdit(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text('수정 완료', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
