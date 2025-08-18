import 'dart:async';
import 'package:flutter/material.dart';

class QuizStartPage extends StatefulWidget {
  final String quizId;
  final String title;
  final int timeMinutes;

  /// 실제 서비스에서는 서버에서 문제를 받아오면 됩니다.
  /// 여기서는 화면 테스트를 위해 리스트를 직접 넣거나, null이면 샘플 데이터를 씁니다.
  final List<QuizQuestion>? questions;

  const QuizStartPage({
    super.key,
    required this.quizId,
    required this.title,
    required this.timeMinutes,
    this.questions,
  });

  @override
  State<QuizStartPage> createState() => _QuizStartPageState();
}

class _QuizStartPageState extends State<QuizStartPage> {
  late final List<QuizQuestion> _questions;
  late final int _totalSeconds;
  late int _secondsLeft;
  Timer? _timer;

  int _index = 0;                       // 현재 문제 인덱스
  final Map<int, int> _answers = {};    // {문제idx: 선택지idx}
  bool _submitted = false;              // 제출 여부

  @override
  void initState() {
    super.initState();
    _questions = widget.questions ?? _sampleQuestions();
    _totalSeconds = widget.timeMinutes * 60;
    _secondsLeft = _totalSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        _autoSubmit();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _autoSubmit() {
    if (_submitted) return;
    setState(() => _submitted = true);
    _showResultSheet();
  }

  void _submitManually() {
    if (_submitted) return;
    _timer?.cancel();
    setState(() => _submitted = true);
    _showResultSheet();
  }

  int _score() {
    int s = 0;
    for (int i = 0; i < _questions.length; i++) {
      final picked = _answers[i];
      if (picked != null && picked == _questions[i].correctIndex) s++;
    }
    return s;
  }

  String _formatMMSS(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showResultSheet() {
    final score = _score();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),
            Text('결과', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
            const SizedBox(height: 4),
            Text(
              '$score / ${_questions.length} 점',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              '제출 후 문제 해설을 확인할 수 있어요.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, {'score': score});
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('나가기'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // 리뷰 모드: 제출 후 해설/정답 표시 (현재 화면 그대로, _submitted=true 상태)
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('해설 보기'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _restart();
                },
                child: const Text('다시 풀기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _restart() {
    setState(() {
      _answers.clear();
      _submitted = false;
      _index = 0;
      _secondsLeft = _totalSeconds;
      _startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_index];
    final picked = _answers[_index];

    final progress = (_index + 1) / _questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(widget.title,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _secondsLeft <= 15 ? Colors.red.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _formatMMSS(_secondsLeft),
                  style: TextStyle(
                    color: _secondsLeft <= 15 ? Colors.red : Colors.blue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            color: Colors.blue,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 / 총문항
              Text('문제 ${_index + 1} / ${_questions.length}',
                  style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),

              // 문제 카드
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q.question,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 14),

                        // 선택지
                        for (int i = 0; i < q.options.length; i++)
                          _OptionTile(
                            index: i,
                            text: q.options[i],
                            selected: picked == i,
                            onTap: _submitted
                                ? null
                                : () => setState(() => _answers[_index] = i),
                            reviewMode: _submitted,
                            correct: q.correctIndex == i,
                            chosenWrong: _submitted && picked == i && picked != q.correctIndex,
                          ),

                        if (_submitted) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    q.explanation,
                                    style: const TextStyle(height: 1.35),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 하단 버튼 영역
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _index == 0 ? null : () => setState(() => _index--),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('이전'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_submitted) {
                          // 리뷰 모드에서는 다음/완료 동작만
                          if (_index < _questions.length - 1) {
                            setState(() => _index++);
                          } else {
                            Navigator.pop(context, {'score': _score()});
                          }
                          return;
                        }

                        if (_index < _questions.length - 1) {
                          setState(() => _index++);
                        } else {
                          // 마지막 문제 -> 제출
                          _submitManually();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(_submitted
                          ? (_index < _questions.length - 1 ? '다음' : '완료')
                          : (_index < _questions.length - 1 ? '다음' : '제출하기')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 샘플 문제
  List<QuizQuestion> _sampleQuestions() => [
    QuizQuestion(
      question: '지진이 발생했을 때 실내에서 가장 먼저 해야 할 행동은?',
      options: ['창문을 연다', '가스 밸브를 잠그고 책상 밑으로 몸을 숨긴다', '엘리베이터로 대피한다', '밖으로 뛰쳐나간다'],
      correctIndex: 1,
      explanation: '실내에서는 떨어지는 물건에 대비해 책상/침대 아래에 몸을 숨기고, 화재 예방을 위해 가스 밸브를 잠그는 것이 우선입니다.',
    ),
    QuizQuestion(
      question: '화재 발생 시 올바른 대피 방법은?',
      options: ['젖은 수건으로 입과 코를 막고 낮은 자세로 이동한다', '엘리베이터를 이용한다', '연기가 많으면 창고에 숨는다', '창문을 깨고 점프한다'],
      correctIndex: 0,
      explanation: '연기는 위로 이동하므로 낮은 자세가 안전하며, 엘리베이터는 정전/질식 위험이 있어 금지입니다.',
    ),
    QuizQuestion(
      question: '태풍 예보 시 사전에 준비해야 할 사항으로 옳지 않은 것은?',
      options: ['창문을 테이프로 고정한다', '야외 물건을 실내로 옮긴다', '하천 주변으로 구경을 나간다', '비상 식수/라디오를 준비한다'],
      correctIndex: 2,
      explanation: '하천/해안 접근은 매우 위험합니다. 외부 물건 정리와 비상물자 준비가 중요합니다.',
    ),
  ];
}

/// ===== 모델 =====
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

/// ===== 옵션 타일 위젯 =====
class _OptionTile extends StatelessWidget {
  final int index;
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  /// 리뷰 모드(제출 후)일 때 색상 처리
  final bool reviewMode;
  final bool correct;     // 이 선택지가 정답인지
  final bool chosenWrong; // 사용자가 선택했고 오답인지

  const _OptionTile({
    required this.index,
    required this.text,
    required this.selected,
    required this.onTap,
    required this.reviewMode,
    required this.correct,
    required this.chosenWrong,
  });

  @override
  Widget build(BuildContext context) {
    Color border = Colors.grey.shade300;
    Color bg = Colors.white;
    Color txt = Colors.black87;
    IconData? icon;

    if (reviewMode) {
      if (correct) {
        border = Colors.green;
        bg = Colors.green.shade50;
        icon = Icons.check_circle;
        txt = Colors.green.shade900;
      } else if (chosenWrong) {
        border = Colors.red;
        bg = Colors.red.shade50;
        icon = Icons.cancel;
        txt = Colors.red.shade900;
      }
    } else if (selected) {
      border = Colors.blue;
      bg = Colors.blue.shade50;
      txt = Colors.blue.shade900;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: reviewMode ? border : (selected ? Colors.blue : Colors.grey.shade400)),
                color: reviewMode
                    ? (correct
                    ? Colors.green
                    : (chosenWrong ? Colors.red : Colors.white))
                    : (selected ? Colors.blue : Colors.white),
              ),
              child: reviewMode
                  ? (icon != null ? Icon(icon, size: 18, color: Colors.white) : Text(_alpha(index),
                  style: TextStyle(
                    color: (correct || chosenWrong) ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  )))
                  : Text(
                _alpha(index),
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 16, color: txt),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _alpha(int i) => String.fromCharCode('A'.codeUnitAt(0) + i);
}
