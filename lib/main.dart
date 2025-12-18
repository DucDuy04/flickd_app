import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Pages
import './pages/splash_page.dart';
import './pages/home_page.dart';

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
      initialRoute: 'home',
      routes: {'home': (BuildContext context) => HomePage()},
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity
            .adaptivePlatformDensity, //tối ưu giao diện theo nền tảng
      ),
      home: HomePage(),
    );
  }
}
