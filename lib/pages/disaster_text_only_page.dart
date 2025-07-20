import 'package:flutter/material.dart';

class DisasterTextOnlyPage extends StatelessWidget {
  final String title;
  final List<String> instructions;

  const DisasterTextOnlyPage({
    super.key,
    required this.title,
    required this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$title 대처 방법')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: instructions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${index + 1}. ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(instructions[index])),
              ],
            ),
          );
        },
      ),
    );
  }
}
