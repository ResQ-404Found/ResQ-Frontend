import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ← 추가
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
  int accumulatedAmount = 0;

  final TextEditingController customAmountController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  String selectedPaymentMethod = '신용카드';

  final amountFormatter = NumberFormat("#,###", "ko_KR");
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isFormatting = false; // ← 입력 포맷 루프 방지용

  @override
  void initState() {
    super.initState();
    // 입력창 리스너: 숫자만 -> 콤마 포맷 + 누적액 동기화
    customAmountController.addListener(() {
      if (_isFormatting) return;
      _isFormatting = true;

      final raw = customAmountController.text.replaceAll(',', '');
      if (raw.isEmpty) {
        accumulatedAmount = 0;
        customAmountController.value = const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
        _isFormatting = false;
        setState(() {});
        return;
      }

      // 숫자 파싱
      final parsed = int.tryParse(raw) ?? 0;
      accumulatedAmount = parsed;

      // 천단위 포맷으로 다시 넣기
      final formatted = amountFormatter.format(parsed);
      customAmountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );

      _isFormatting = false;
      setState(() {});
    });
  }

  @override
  void dispose() {
    customAmountController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void _syncAmountField() {
    final text = accumulatedAmount == 0 ? '' : amountFormatter.format(accumulatedAmount);
    _isFormatting = true;
    customAmountController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _isFormatting = false;
    setState(() {});
  }

  Future<void> submitDonation(int sponsorId, int amount, String message) async {
    final token = await _secureStorage.read(key: 'accessToken');

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.redAccent,
                    child: Icon(Icons.favorite, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '후원 완료!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '후원해주셔서 감사합니다.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(context, '/donation');
                      },
                      child: const Text(
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('후원 실패 ㅠㅠ')));
    }
  }

  void handleSubmit(Donation donation) {
    final amount = accumulatedAmount; // 입력/칩 모두 accumulatedAmount로 일원화
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('후원 금액을 입력해주세요.')));
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
        title: const Text('후원하기'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 35),
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
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donation.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(donation.sponsorName, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('후원 금액 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: amountOptions.map((amount) {
                return ActionChip(
                  label: Text('+ ${amountFormatter.format(amount)}원'),
                  backgroundColor: Colors.grey[200],
                  onPressed: () {
                    setState(() {
                      accumulatedAmount += amount; // 누적
                      _syncAmountField();           // 입력창 동기화
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 15),

            // 직접 입력 가능: 숫자만, 콤마 자동
            TextField(
              controller: customAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.attach_money),
                labelText: '후원 금액',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  tooltip: '금액 초기화',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    accumulatedAmount = 0;
                    _syncAmountField();
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text('결제 방식 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Column(
              children: ['신용카드', '계좌이체', '간편결제'].map((method) {
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

            const SizedBox(height: 24),

            const Text('응원 메시지 (선택사항)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '응원 메시지를 남겨주세요',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 80),
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
              '${accumulatedAmount == 0 ? 0 : amountFormatter.format(accumulatedAmount)}원 결제하기',
              style: const TextStyle(
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
