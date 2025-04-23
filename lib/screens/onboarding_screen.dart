import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'package:project/widgets/onboarding_page.dart';
import 'package:project/widgets/page_indicator.dart';
import '../core/constants/colors.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> onboardingData = [
    {
      'kcal': 'ZUAMICA',
      'title': 'Eat Healthy',
      'subtitle': 'Maintaining good health should be the primary focus of everyone.',
      'time': '8:41',
      'image': 'assets/images/onboarding1.png',
    },
    {
      'kcal': 'Healthy Recipes',
      'title': 'Discover Recipes',
      'subtitle': 'Browse thousands of healthy recipes from all over the world.',
      'time': '8:41',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'kcal': 'Track Progress',
      'title': 'Track Your Health',
      'subtitle': 'With amazing inbuilt tools you can track your progress.',
      'time': '8:41',
      'image': 'assets/images/onboarding3.png',
    },
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Time indicator (mock)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    onboardingData[_currentPage]['time']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    kcal: onboardingData[index]['kcal']!,
                    title: onboardingData[index]['title']!,
                    subtitle: onboardingData[index]['subtitle']!,
                    buttonText: 'Get Started',
                    loginText: 'Already Have An Account? Log in',
                    onPressed: _navigateToHome,
                  );
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: PageIndicator(
                currentPage: _currentPage,
                pageCount: onboardingData.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}