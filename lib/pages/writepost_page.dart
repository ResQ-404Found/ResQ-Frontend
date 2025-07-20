import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  final List<String> regions = ['서울', '부산', '대구', '광주', '인천', '제주'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
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

            // 작성 완료 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // 작성 완료 시 실행할 로직
                },
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
