import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'donation_list_page.dart';

class DonationPaymentPage extends StatefulWidget {
  @override
  State<DonationPaymentPage> createState() => _DonationPaymentPageState();
}

class _DonationPaymentPageState extends State<DonationPaymentPage> {
  int selectedAmount = 10000;

  Future<void> submitDonation(int sponsorId, int amount) async {
    final uri = Uri.parse('http://54.253.211.96:8000/api/sponsor/$sponsorId/donate?amount=$amount');
    final response = await http.post(uri);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('후원이 완료되었습니다!')));
      Navigator.popUntil(context, ModalRoute.withName('/'));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('후원 실패 ㅠㅠ')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final donation = ModalRoute.of(context)!.settings.arguments as Donation;

    return Scaffold(
      appBar: AppBar(title: Text('후원하기')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(donation.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('후원 금액 선택'),
            Wrap(
              spacing: 10,
              children: [10000, 30000, 50000, 100000].map((amount) {
                return ChoiceChip(
                  label: Text('${amount ~/ 10000},000원'),
                  selected: selectedAmount == amount,
                  onSelected: (_) => setState(() => selectedAmount = amount),
                );
              }).toList(),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => submitDonation(donation.id, selectedAmount),
                child: Text('결제하기'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
