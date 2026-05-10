import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/mezban_logo.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

/// Splash screen that checks authentication status on app startup
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize authentication state
    final auth = context.read<AuthProvider>();
    await auth.initializeAuth();

    // 4 second delay as requested
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      // Always navigate to DashboardScreen so guest users can see the home page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: MezbanLogo(fontSize: 180, showText: false),
      ),
    );
  }
}
