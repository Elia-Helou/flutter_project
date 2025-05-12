import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home_screen.dart';
import 'providers/user_provider.dart';
import 'routes/app_routes.dart';
import 'screens/bmi_calculator_screen.dart';
import 'services/deep_link_service.dart';
// import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await DatabaseService.instance.connection;
  } catch (e) {
    // Error will be logged by the database service
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DeepLinkService? _deepLinkService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _deepLinkService?.dispose();
    _deepLinkService = DeepLinkService(context);
  }

  @override
  void dispose() {
    _deepLinkService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Splash Onboarding',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: Consumer<AuthService>(
          builder: (context, authService, _) {
            if (authService.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return authService.isLoggedIn ? const HomeScreen() : const SplashScreen();
          },
        ),
        routes: Map<String, WidgetBuilder>.from(AppRoutes.routes)
          ..addAll({
            '/bmi': (context) => const BMICalculatorScreen(),
          }),
      ),
    );
  }
}