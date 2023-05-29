import 'package:flutter/material.dart';
import 'package:simple_interest_calculator/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Interest Calculator',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.yellow,
      ),
      home: HomeScreen(),
    );
  }
}
