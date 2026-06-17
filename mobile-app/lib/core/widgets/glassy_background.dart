import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassyBackground extends StatelessWidget {
  final Widget child;

  const GlassyBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Solid base color
        Container(
          color: const Color(0xFFF4F6F9),
        ),
        // Soft backdrop gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEBF1FA),
                Color(0xFFF3F6FA),
                Color(0xFFE8EEF5),
              ],
            ),
          ),
        ),
        // Soft Saffron Blob at top right
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.saffron.withOpacity(0.08),
            ),
          ),
        ),
        // Soft Primary Blue Blob at center left
        Positioned(
          top: 300,
          left: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue.withOpacity(0.06),
            ),
          ),
        ),
        // Soft Campaign Purple Blob at bottom right
        Positioned(
          bottom: -100,
          right: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.campaignPurple.withOpacity(0.06),
            ),
          ),
        ),
        // Main Screen Content
        child,
      ],
    );
  }
}
