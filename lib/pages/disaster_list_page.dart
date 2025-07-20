import 'package:flutter/material.dart';

class DisasterListPage extends StatelessWidget {
  const DisasterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final disasterTypes = [
      {'title': '화재', 'route': '/fire'},
      {'title': '산사태', 'route': '/landslide'},
      {'title': '홍수', 'route': '/flood'},
      {'title': '태풍', 'route': '/typhoon'},
      {'title': '지진', 'route': '/earthquake'},
      {'title': '한파', 'route': '/coldwave'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('대처 방법 목록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: disasterTypes.length,
        itemBuilder: (context, index) {
          final disaster = disasterTypes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, disaster['route']!),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  disaster['title']!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),

    );
  }
}
