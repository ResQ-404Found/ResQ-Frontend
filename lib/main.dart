import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _handleDeepLinks();
  }

  void _handleDeepLinks() async {
    _appLinks.uriLinkStream.listen((uri) {
      final token = uri?.queryParameters['token'];
      if (token != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(context, '/new-password', arguments: token);
        });
      }
    });

    final initialUri = await _appLinks.getInitialAppLink();
    final token = initialUri?.queryParameters['token'];
    if (token != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamed(context, '/new-password', arguments: token);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/initial',
      routes: appRoutes,
    );
  }
}
