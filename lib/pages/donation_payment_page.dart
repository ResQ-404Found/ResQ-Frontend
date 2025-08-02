import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'donation_list_page.dart';

class DonationPaymentPage extends StatefulWidget {
  const DonationPaymentPage({super.key});

  @override
  State<DonationPaymentPage> createState() => _DonationPaymentPageState();
}

class _DonationPaymentPageState extends State<DonationPaymentPage> {
  int? selectedAmount;
  final TextEditingController customAmountController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  String selectedPaymentMethod = '신용카드';

  final amountFormatter = NumberFormat("#,###", "ko_KR");
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> submitDonation(int sponsorId, int amount, String message) async {
    final token = await _secureStorage.read(key: 'accessToken');

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    final uri = Uri.parse(
      'http://54.253.211.96:8000/api/sponsor/$sponsorId/donate?amount=$amount&message=${Uri.encodeComponent(message)}',
    );

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final earnedPoint = (amount * 0.1).floor();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        '+${NumberFormat("#,###", "ko_KR").format(earnedPoint)} 포인트 적립!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.redAccent,
                    child: Icon(Icons.favorite, color: Colors.white, size: 30),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '후원 완료!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '후원해주셔서 감사합니다.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(context, '/donation');
                      },
                      child: Text(
                        '후원 목록으로 가기',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('후원 실패 ㅠㅠ')));
    }
  }

  void handleSubmit(Donation donation) {
    final custom = int.tryParse(
      customAmountController.text.replaceAll(',', ''),
    );
    final amount = selectedAmount ?? custom ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('후원 금액을 입력해주세요.')));
      return;
    }

    submitDonation(donation.id, amount, messageController.text);
  }

  @override
  Widget build(BuildContext context) {
    final donation = ModalRoute.of(context)!.settings.arguments as Donation;
    final amountOptions = [10000, 30000, 50000, 100000];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('후원하기'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donation.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    donation.sponsorName,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              '후원 금액 선택',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  amountOptions.map((amount) {
                    return ChoiceChip(
                      label: Text('${amountFormatter.format(amount)}원'),
                      selected: selectedAmount == amount,
                      selectedColor: Colors.redAccent,
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color:
                            selectedAmount == amount
                                ? Colors.white
                                : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedAmount = amount;
                          customAmountController.clear();
                        });
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: 16),
            TextField(
              controller: customAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money),
                labelText: '직접 입력 (숫자만)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (digitsOnly.isEmpty) {
                  customAmountController.text = '';
                  selectedAmount = null;
                  return;
                }
                final formatted = amountFormatter.format(int.parse(digitsOnly));
                customAmountController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
                setState(() {
                  selectedAmount = null;
                });
              },
            ),
            SizedBox(height: 24),
            Text(
              '결제 방식 선택',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Column(
              children:
                  ['신용카드', '계좌이체', '간편결제'].map((method) {
                    return RadioListTile<String>(
                      activeColor: Colors.redAccent,
                      title: Text(method),
                      value: method,
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: 24),
            Text(
              '응원 메시지 (선택사항)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '응원 메시지를 남겨주세요',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => handleSubmit(donation),
            child: Text(
              '${amountFormatter.format(selectedAmount ?? int.tryParse(customAmountController.text.replaceAll(',', '')) ?? 0)}원 결제하기',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
