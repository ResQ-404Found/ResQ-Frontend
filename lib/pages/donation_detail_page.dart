import 'package:flutter/material.dart';
import 'donation_list_page.dart';

class DonationDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final donation = ModalRoute.of(context)!.settings.arguments as Donation;

    return Scaffold(
      appBar: AppBar(title: Text('후원 상세')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(donation.imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover),
            SizedBox(height: 16),
            Text(donation.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(donation.sponsorName, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text('기간: ${donation.startDate} ~ ${donation.dueDate}'),
            SizedBox(height: 16),
            Row(
              children: [
                Text('${donation.currentMoney ~/ 10000}만원', style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text('목표 ${donation.targetMoney ~/ 10000}만원'),
              ],
            ),
            LinearProgressIndicator(
              value: donation.progress,
              minHeight: 6,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text('후원 내용', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(donation.content),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/payment', arguments: donation),
                child: Text('후원하기'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
