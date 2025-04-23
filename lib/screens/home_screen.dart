import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text(
          'Welcome to the App!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}