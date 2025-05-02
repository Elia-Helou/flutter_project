import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/colors.dart';
import 'package:project/widgets/onboarding_page.dart';
import 'package:project/widgets/page_indicator.dart';
import '../core/constants/colors.dart';
import 'auth/login_screen.dart';

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
      'image': 'assets/images/onboarding/onboarding1.png',
    },
    {
      'kcal': 'Healthy Recipes',
      'title': 'Discover Recipes',
      'subtitle': 'Browse thousands of healthy recipes from all over the world.',
      'image': 'assets/images/onboarding/onboarding2.png',
    },
    {
      'kcal': 'Track Progress',
      'title': 'Track Your Health',
      'subtitle': 'With amazing inbuilt tools you can track your progress.',
      'image': 'assets/images/onboarding/onboarding3.png',
    },
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to be transparent and use dark icons for light background
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top 'kcal' text
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text(
                onboardingData[_currentPage]['kcal']!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.splashBackground,
                ),
              ),
            ),

            // Page view for onboarding content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    imagePath: onboardingData[index]['image']!,
                    title: onboardingData[index]['title']!,
                    subtitle: onboardingData[index]['subtitle']!,
                    buttonText: 'Get Started',
                    loginText: 'Already Have An Account? Log In',
                    onGetStartedPressed: _navigateToLogin,
                  );
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: PageIndicator(
                currentPage: _currentPage,
                pageCount: onboardingData.length,
                activeColor: AppColors.textSecondary,
                inactiveColor: AppColors.textSecondary.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}