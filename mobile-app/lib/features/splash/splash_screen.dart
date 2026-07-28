import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glassy_background.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _progressController.forward();
    _startTimer();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _startTimer() async {
    // Start preferences retrieval concurrently with the 5s timer
    final prefsFuture = SharedPreferences.getInstance();

    // Wait exactly 5 seconds
    await Future.delayed(const Duration(seconds: 5));

    final prefs = await prefsFuture;
    final String? token = prefs.getString('auth_token');
    final bool isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

    if (isFirstLaunch) {
      await prefs.setBool('is_first_launch', false);
    }

    if (!mounted) return;

    Widget targetScreen;
    if (token != null && token.isNotEmpty) {
      targetScreen = const HomeScreen();
    } else if (isFirstLaunch) {
      targetScreen = const RegisterScreen();
    } else {
      targetScreen = const LoginScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassyBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Circular Logo with subtle glow/shadow
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.15),
                              blurRadius: 25,
                              spreadRadius: 5,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.9),
                            width: 4.5,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ).animate().fadeIn(duration: 1000.ms).scale(duration: 800.ms, curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 32),
                      
                      // App Name
                      const Text(
                        'Veerangna',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                          letterSpacing: 1.5,
                        ),
                      ).animate().fadeIn(delay: 300.ms, duration: 800.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                      
                      const SizedBox(height: 16),
                      
                      // Trust name
                      const Text(
                        'late. Champaben Madhavjibhai Ratanshibhai Thakkar Charitable Trust',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          height: 1.5,
                          letterSpacing: 0.2,
                        ),
                      ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                      
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
              
              // Loading Progress Bar at the bottom
              Positioned(
                bottom: 50,
                left: 40,
                right: 40,
                child: Column(
                  children: [
                    // Frosted Glass Progress Track
                    Container(
                      height: 5,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 0.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _progressController.value,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryBlue,
                                      AppColors.saffron,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'LOADING...',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary.withOpacity(0.7),
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 900.ms, duration: 600.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
