// Add your screen imports here
import 'package:project/screens/splash_screen.dart';
import 'package:project/screens/onboarding_screen.dart';
import 'package:project/screens/auth/login_screen.dart';
import 'package:project/screens/auth/signup_screen.dart';
import 'package:project/screens/home_screen.dart';
// import 'package:project/screens/search_screen.dart';
// import 'package:project/screens/add_screen.dart';
// import 'package:project/screens/favorites_screen.dart';
// import 'package:project/screens/profile_screen.dart';

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

  static Map<String, dynamic> routes = {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    home: (context) => const HomeScreen(),
    // search: (context) => const SearchScreen(),
    // add: (context) => const AddScreen(),
    // favorites: (context) => const FavoritesScreen(),
    // profile: (context) => const ProfileScreen(),
  };
}
