import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import các trang:
import './pages/splash_page.dart';
import './pages/home_page.dart';
import './pages/auth_page.dart';

void main() {
  runApp(
    SplashPage(
      key: UniqueKey(),
      onInitializationComplete: () => runApp(ProviderScope(child: MyApp())),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flickd',
      debugShowCheckedModeBanner: false,
      initialRoute: 'auth', // <-- BẮT ĐẦU từ login
      routes: {
        'auth': (context) => AuthPage(),
        'home': (context) => HomePage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
