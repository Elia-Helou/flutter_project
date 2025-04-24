import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for SystemChrome
import 'package:project/core/constants/colors.dart';
import 'package:project/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Set status bar color to match background
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.splashBackground,
      statusBarIconBrightness: Brightness.light, // Use light icons on dark background
    ));

    Timer(
      const Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(), // Pushes content to center
            const Text(
              'kcal',
              style: TextStyle(
                fontSize: 80, // Adjust size as needed
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(), // Pushes ZUAMICA to bottom
            const Text(
              'ZUAMICA',
              style: TextStyle(
                fontSize: 24, // Adjust size as needed
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 50), // Add some padding at the bottom
          ],
        ),
      ),
    );
  }
}
