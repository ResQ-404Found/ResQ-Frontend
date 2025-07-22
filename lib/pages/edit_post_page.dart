import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'dart:convert';

class EditPostPage extends StatefulWidget {
  const EditPostPage({super.key});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> post;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  int? selectedRegionId;
  List<String> existingImageURLs = [];
  List<XFile> newImages = [];

  final ImagePicker _picker = ImagePicker();

  final Map<String, int> regionIdMap = {
    '서울': 1, '부산': 2559, '대구': 2784, '인천': 2011, '광주': 3235,
    '대전': 3481, '울산': 3664, '세종': 3759, '경기': 3793, '강원': 5660,
    '충북': 6129, '충남': 6580, '전북': 7376, '전남': 8143,
    '경북': 9073, '경남': 10404, '제주': 11977,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    post = ModalRoute.of(context as BuildContext)?.settings.arguments as Map<String, dynamic>;
    titleController.text = post['title'] ?? '';
    contentController.text = post['content'] ?? '';
    selectedRegionId = post['region_id'];
    existingImageURLs = List<String>.from(post['post_imageURLs'] ?? []);
  }

  Future<void> pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() => newImages.addAll(picked));
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse('http://54.253.211.96:8000/api/posts/${post['id']}');
    final request = http.MultipartRequest('PATCH', url);

    request.fields['title'] = titleController.text;
    request.fields['content'] = contentController.text;
    if (selectedRegionId != null) {
      request.fields['region_id'] = selectedRegionId.toString();
    }

    request.fields['post_imageURLs'] = jsonEncode(existingImageURLs);

    for (var image in newImages) {
      final fileBytes = await image.readAsBytes();
      final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';

      request.files.add(http.MultipartFile.fromBytes(
        'files',
        fileBytes,
        filename: basename(image.path),
        contentType: MediaType.parse(mimeType),
      ));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      if (mounted) {
        Navigator.pop(context as BuildContext);
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(content: Text('게시글이 수정되었습니다.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('수정 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시글 수정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: '제목'),
                validator: (value) => value!.isEmpty ? '제목을 입력하세요' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: contentController,
                decoration: const InputDecoration(labelText: '내용'),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? '내용을 입력하세요' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: selectedRegionId,
                decoration: const InputDecoration(labelText: '지역'),
                items: regionIdMap.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.value,
                    child: Text(entry.key),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedRegionId = val),
              ),
              const SizedBox(height: 12),
              const Text('기존 이미지', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (existingImageURLs.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: existingImageURLs.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Image.network(existingImageURLs[index], height: 100),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                setState(() => existingImageURLs.removeAt(index));
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: pickImages,
                icon: const Icon(Icons.image),
                label: const Text('이미지 추가'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: newImages.map((img) {
                  return Image.file(File(img.path), height: 100);
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: submit,
                child: const Text('수정 완료'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
