import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/login",
      routes: {
        "/login": (context) => const LoginPage(),
        "/home": (context) => const HomePage(),
      },
    );
  }
}
