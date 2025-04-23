import 'package:flutter/material.dart';

import '../core/constants/colors.dart';

class OnboardingPage extends StatelessWidget {
  final String kcal;
  final String title;
  final String subtitle;
  final String buttonText;
  final String loginText;
  final VoidCallback onPressed;

  const OnboardingPage({
    super.key,
    required this.kcal,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.loginText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Kcal indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.kcalBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              kcal,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Subtitle
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Get Started button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Login text
          TextButton(
            onPressed: onPressed,
            child: Text(
              loginText,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}