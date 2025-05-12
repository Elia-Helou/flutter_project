// Add your screen imports here
import 'package:project/screens/splash_screen.dart';
import 'package:project/screens/onboarding_screen.dart';
import 'package:project/screens/auth/login_screen.dart';
import 'package:project/screens/auth/signup_screen.dart';
import 'package:project/screens/home_screen.dart';
import 'package:project/screens/profile_screen.dart';
import 'package:project/screens/scan_food_screen.dart';
import 'package:project/screens/diary_screen.dart';
// import 'package:project/screens/search_screen.dart';
import 'package:project/screens/search_screen.dart';
// import 'package:project/screens/add_screen.dart';
// import 'package:project/screens/favorites_screen.dart';
import 'package:project/screens/auth/forgot_password_screen.dart';
import 'package:project/screens/auth/reset_password_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String search = '/search';
  static const String add = '/add';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String scanFood = '/scanFood';
  static const String diary = '/diary';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    home: (context) => const HomeScreen(),
    search: (context) => const SearchScreen(),
    // add: (context) => const AddScreen(),
    // favorites: (context) => const FavoritesScreen(),
    profile: (context) => const ProfileScreen(),
    scanFood: (context) => const ScanFoodScreen(),
    diary: (context) => const DiaryScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    resetPassword: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return ResetPasswordScreen(
        email: args['email'],
        token: args['token'],
      );
    },
  };
}
