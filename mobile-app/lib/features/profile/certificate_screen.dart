import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glassy_background.dart';
import '../../core/widgets/glassy_container.dart';
import '../../data/models/user_model.dart';
import 'certificate_detail_screen.dart';

class CertificateScreen extends StatefulWidget {
  final UserModel user;

  const CertificateScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  @override
  Widget build(BuildContext context) {
    // Determine join date string (fallback to today if parsing fails)
    String joinedDate = '2023';
    try {
      if (widget.user.createdAt != null) {
        joinedDate = DateFormat('MMMM d, yyyy').format(DateTime.parse(widget.user.createdAt!));
      } else {
        joinedDate = DateFormat('MMMM d, yyyy').format(DateTime.now());
      }
    } catch (e) {
      joinedDate = DateFormat('MMMM d, yyyy').format(DateTime.now());
    }

    final donationHistory = widget.user.donationHistory;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Certificates', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue.withOpacity(0.65),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: GlassyBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Verified Credentials',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),
                    const SizedBox(height: 6),
                    Text(
                      'Select a certificate to view details, share, or download as PDF.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: 1 + donationHistory.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Membership Certificate Tile
                      return GlassyContainer(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        opacity: 0.1,
                        borderRadius: BorderRadius.circular(16),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.saffron.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified_user_rounded, color: AppColors.saffron, size: 28),
                          ),
                          title: const Text(
                            'Membership Certificate',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDarkBlue),
                          ),
                          subtitle: Text(
                            'Official Member since $joinedDate',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primaryBlue),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CertificateDetailScreen(
                                  user: widget.user,
                                  joinedDate: joinedDate,
                                ),
                              ),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
                    } else {
                      // Donation Certificate Tile
                      final donation = donationHistory[index - 1];
                      final amount = donation['amount'] ?? 0;
                      
                      String donationDate = 'Recent';
                      try {
                        if (donation['createdAt'] != null) {
                          donationDate = DateFormat('MMM d, yyyy').format(DateTime.parse(donation['createdAt']));
                        }
                      } catch (_) {}

                      final campaignTitle = donation['campaign'] != null ? donation['campaign']['title'] : 'Campaign Support';

                      return GlassyContainer(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        opacity: 0.08,
                        borderRadius: BorderRadius.circular(16),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.volunteer_activism_rounded, color: AppColors.primaryBlue, size: 28),
                          ),
                          title: Text(
                            'Donation Certificate (₹$amount)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDarkBlue),
                          ),
                          subtitle: Text(
                            '$campaignTitle\nDate: $donationDate',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primaryBlue),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CertificateDetailScreen(
                                  user: widget.user,
                                  donation: donation,
                                  joinedDate: joinedDate,
                                ),
                              ),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: (200 + (index * 50)).ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
