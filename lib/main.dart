// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// //Pages
// import './pages/splash_page.dart';
// import './pages/home_page.dart';

// void main() {
//   runApp(
//     SplashPage(
//       key: UniqueKey(),
//       onInitializationComplete: () => runApp(ProviderScope(child: MyApp())),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flickd',
//       initialRoute: 'home',
//       routes: {'home': (BuildContext context) => HomePage()},
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity
//             .adaptivePlatformDensity, //tối ưu giao diện theo nền tảng
//       ),
//       home: HomePage(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import các trang:
import './pages/splash_page.dart';
import './pages/home_page.dart';
import './pages/login_page.dart';
import './pages/register_page.dart'; // Trang đăng ký mới

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
      initialRoute: 'login', // <-- BẮT ĐẦU từ login
      routes: {
        'login': (context) => LoginPage(),
        'register': (context) => RegisterPage(),
        'home': (context) => HomePage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
