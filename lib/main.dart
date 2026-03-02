import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GuardianAngelApp());
}

class GuardianAngelApp extends StatelessWidget {
  const GuardianAngelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian Angel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}