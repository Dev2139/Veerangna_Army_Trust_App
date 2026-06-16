import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/login_screen.dart';

void main() {
  runApp(const ArmyDonationApp());
}

class ArmyDonationApp extends StatelessWidget {
  const ArmyDonationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Army Trust',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.armyGreen,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.armyGreen),
        fontFamily: 'Inter', // Assuming Inter font is added to pubspec.yaml
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
