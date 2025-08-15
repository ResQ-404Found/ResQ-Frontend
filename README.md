### 2025-Spring-Project-Frontend
### team 404Found

### 개발환경 설치
[Flutter 공식 설치 가이드 (Windows)](https://docs.flutter.dev/get-started/install/windows)
```
Flutter 설치
1) 위 링크로 가서 Flutter SDK 다운로드
2) 적당한 경로에 압축 해제 ( ex) C:\src\flutter)
3) 시스템 환경변수 > Path > C:\src\flutter\bin 추가
4) cmd에 flutter doctor 명령어 입력
5) Android Studio 설치 및  Android SDK 설정

패키지 설치
flutter pub get

에뮬레이터 실행
flutter devices
flutter run
```

### 프로젝트 구조
```
project-root/
│
├── lib/
│   ├── main.dart
│   ├── routes.dart
│   ├── firebase_options.dart
│   ├── api/
│      ├── http_client.dart
│   ├── asset/
│      ├── 글자없는로고.png
│   └── pages/
│      ├── allposts_page.dart
│      ├── chatbot_page.dart
│      ├── coldwave_page.dart
│      ├── community_page.dart
│      ├── disaster_detail_page.dart
│      ├── disaster_list_page.dart
│      ├── disaster_menu_page.dart
│      ├── disaster_text_only_page.dart
│      ├── disastertype_filtering_page.dart
│      ├── earthquake_page.dart
│      ├── fire_page.dart
│      ├── firebase_page.dart
│      ├── flood_page.dart
│      ├── hotposts_page.dart
│      ├── landslide_page.dart
│      ├── login_page.dart
│      ├── map_page.dart
│      ├── password_reset_new_page.dart
│      ├── password_reset_request_page.dart
│      ├── password_reset_verify_page.dart
│      ├── region_category_page.dart
│      ├── signup_page.dart
│      ├── typhoon_page.dart
│      ├── user_page.dart
│      ├── withdrawl_page.dart
│      └── writepost_page.dart
│
├── pubspec.yaml 
├── analysis_options.yaml
├── .gitignore
├── README.md4    
```
