import 'package:flutter/material.dart';
import 'main_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GEMA App',
      debugShowCheckedModeBanner: false,
      home: const MainNavigationPage(),
    );
  }
}
