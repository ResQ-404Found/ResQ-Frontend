import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class EditPostPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

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

  String? _selectedRegionName;
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.post['title'] ?? '';
    _contentController.text = widget.post['content'] ?? '';
    _imageUrls = List<String>.from(widget.post['post_imageURLs'] ?? []);

    int? regionId = widget.post['region_id'];
    _selectedRegionName = regionIdMap.entries
        .firstWhere((entry) => entry.value == regionId, orElse: () => const MapEntry('', 0))
        .key;
  }

  Future<void> updatePost() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    final postId = widget.post['id'];

    final response = await http.patch(
      Uri.parse('http://54.253.211.96:8000/api/posts/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': _titleController.text,
        'content': _contentController.text,
        'region_id': _selectedRegionName != null ? regionIdMap[_selectedRegionName] : null,
        'post_imageURLs': _imageUrls,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('수정 완료!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정 실패: ${response.statusCode}')),
      );
    }
  }

  void addImageUrl() {
    final url = _imageUrlController.text.trim();
    if (url.isNotEmpty) {
      setState(() {
        _imageUrls.add(url);
        _imageUrlController.clear();
      });
    }
  }

  void removeImageUrl(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시글 수정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: '내용'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedRegionName,
              items: regions.map((regionName) {
                return DropdownMenuItem<String>(
                  value: regionName,
                  child: Text(regionName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRegionName = value;
                });
              },
              decoration: const InputDecoration(labelText: '지역 선택'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(labelText: '이미지 URL 추가'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addImageUrl,
                )
              ],
            ),
            Column(
              children: _imageUrls
                  .asMap()
                  .entries
                  .map((entry) => ListTile(
                leading: Image.network(entry.value, width: 50, height: 50, fit: BoxFit.cover),
                title: Text(entry.value),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => removeImageUrl(entry.key),
                ),
              ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updatePost,
              child: const Text('수정 완료'),
            ),
          ],
        ),
      ),
    );
  }
}
