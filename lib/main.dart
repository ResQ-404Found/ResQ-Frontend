import 'package:flutter/material.dart'; // Flutter의 기본 위젯 및 UI 관련 기능들 제공
// import 'package:uni_links/uni_links.dart'; // 앱이 URL(딥링크)을 통해 호출될 때, 그 링크를 처리할 수 있도록 돕는 패키지
// flutter 버진이랑 안 맞아서 지금 쓸 수 없음 
import 'dart:async'; // Stream, Future, StreamSubscription 등을 사용하기 위해 필요
import 'routes.dart'; // 앱의 링크 피일 

// 앱 실행의 진입점
void main() {
  runApp(const MyApp());
}

// 이 앱은 상태가 변화할 수 있기 때문에 StatefulWidget으로 선언됨
// 위젯의 상태를 _MyAppState에서 정의
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/* 
// 이거 uni link 쓸 때 써야하는데 지금 못 씀
// 딥링크 스트림을 구독하기 위한 변수 나중에 dispose()에서 구독을 해제해 메모리 누수를 방지함
class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  // 위젯이 처음 생성될 때 호출됨 , _handleIncomingLinks() 를 통해 딥링크 스트림 구독 시작
  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  // uriLinkStream 은 앱이 외부 링크(예: 이메일 클릭 등)로 열릴 때 발생하는 이벤트 스트림
  해당 링크에서 token이라는 쿼리 파라미터 값을 추출
  예: http://api/reset-password?token=abc123
  token이 존재하면, /new-password 라우트로 이동하며 그 값을 arguments로 넘김

  void _handleIncomingLinks() {
    _sub = uriLinkStream.listen((Uri? uri) { 
      final token = uri?.queryParameters['token'];
      if (token != null) {
        Navigator.pushNamed(context, '/new-password', arguments: token);
      }
    });
  }

  // 앱이 종료될 때 스트림 구독을 종료하여 리소스 누수를 막음
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
*/

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/initial',
      routes: appRoutes,
    );
  }
