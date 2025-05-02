import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../core/constants/colors.dart';

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String buttonText;
  final String loginText;
  final VoidCallback onGetStartedPressed;

  const OnboardingPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.loginText,
    required this.onGetStartedPressed,
    // this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Split login text for styling
    final loginParts = loginText.split('Log In');
    final regularText = loginParts[0]; // "Already Have An Account? "
    const linkText = 'Log In'; // "Log In"

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0), // Adjusted horizontal padding
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // Align content towards start
        children: [
          const SizedBox(height: 20), // Space from top 'kcal' text

          // Image
          Expanded(
            flex: 5, // Give more space to the image
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain, // Ensure image fits well
            ),
          ),

          const SizedBox(height: 40), // Space below image

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 22, // Adjusted size
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 15), // Space below title

          // Subtitle
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14, // Adjusted size
              color: AppColors.textSecondary,
              height: 1.4, // Adjusted line height
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 2), // Pushes button and login text down

          // Get Started button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onGetStartedPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.splashBackground, // Use splash green color
                padding: const EdgeInsets.symmetric(vertical: 18), // Adjusted padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // More rounded corners
                ),
                elevation: 0, // Remove shadow
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text
                ),
              ),
            ),
          ),

          const SizedBox(height: 20), // Space below button

          // Login text
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              children: <TextSpan>[
                TextSpan(text: regularText),
                TextSpan(
                  text: linkText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.splashBackground, // Use splash green for link
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // TODO: Implement login navigation/action
                      print("Log In tapped!");
                      // if (onLoginPressed != null) onLoginPressed!();
                    },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), // Space at the bottom before indicator
        ],
      ),
    );
  }
}