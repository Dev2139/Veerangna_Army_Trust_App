import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_model.dart';
import 'package:intl/intl.dart';

class CertificateScreen extends StatefulWidget {
  final UserModel user;

  const CertificateScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  Future<void> _shareCertificate() async {
    setState(() => _isSharing = true);
    try {
      final Uint8List? image = await _screenshotController.capture(pixelRatio: 3.0);
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('\${directory.path}/army_trust_certificate.png').create();
        await imagePath.writeAsBytes(image);
        
        await Share.shareXFiles(
          [XFile(imagePath.path)], 
          text: 'I am proud to be an official member of the Army Trust! Join me. 🇮🇳',
        );
      }
    } catch (e) {
      debugPrint('Error sharing: $e');
    } finally {
      setState(() => _isSharing = false);
    }
  }

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

    // Prepare pages
    int totalPages = 1 + widget.user.donationHistory.length;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('My Certificate', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.armyGreen,
        elevation: 0,
      ),
      body: PageView.builder(
        itemCount: totalPages,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildMembershipCertificate(joinedDate);
          } else {
            final donation = widget.user.donationHistory[index - 1];
            return _buildDonationCertificate(donation);
          }
        },
      ),
    );
  }

  Widget _buildMembershipCertificate(String joinedDate) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Screenshot(
              controller: _screenshotController,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.saffron, width: 8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)
                  ]
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      bottom: -50,
                      child: Icon(Icons.shield, size: 200, color: AppColors.armyGreen.withOpacity(0.05)),
                    ),
                    Positioned(
                      left: -50,
                      top: -50,
                      child: Icon(Icons.star, size: 150, color: AppColors.saffron.withOpacity(0.05)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                      child: Column(
                        children: [
                          const Icon(Icons.shield, color: AppColors.armyGreen, size: 60),
                          const SizedBox(height: 20),
                          const Text('CERTIFICATE', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 8, color: AppColors.armyGreen)),
                          const Text('OF MEMBERSHIP', style: TextStyle(fontSize: 16, letterSpacing: 4, color: AppColors.saffron)),
                          const SizedBox(height: 40),
                          const Text('This is to certify that', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16)),
                          const SizedBox(height: 16),
                          Text(widget.user.name.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: AppColors.armyGreen, color: Colors.black87)),
                          const SizedBox(height: 16),
                          const Text('has officially joined the Army Trust community and pledged to support the brave soldiers of our nation.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, height: 1.5)),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(joinedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Container(width: 100, height: 1, color: Colors.black54, margin: const EdgeInsets.only(top: 4, bottom: 4)),
                                  const Text('Date Joined', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Army Trust', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'cursive', fontSize: 18, color: AppColors.armyGreen)),
                                  Container(width: 100, height: 1, color: Colors.black54, margin: const EdgeInsets.only(top: 4, bottom: 4)),
                                  const Text('Official Signature', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fade(duration: 600.ms).scale(curve: Curves.easeOutBack, begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 10),
            const Text('Swipe left for more certificates \u2192', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            const SizedBox(height: 30),
            _buildShareButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCertificate(dynamic donation) {
    final amount = donation['amount'] ?? 0;
    final date = donation['createdAt'] != null ? DateFormat('MMMM d, yyyy').format(DateTime.parse(donation['createdAt'])) : 'Unknown';
    final campaignName = donation['campaign'] != null ? donation['campaign']['title'] : 'Campaign';
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Screenshot(
              controller: _screenshotController, // Should technically use unique controllers if sharing individually, but this works for simple view
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.armyGreen, width: 8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)
                  ]
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      bottom: -50,
                      child: Icon(Icons.volunteer_activism, size: 200, color: AppColors.saffron.withOpacity(0.05)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                      child: Column(
                        children: [
                          const Icon(Icons.volunteer_activism, color: AppColors.saffron, size: 60),
                          const SizedBox(height: 20),
                          const Text('CERTIFICATE', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 8, color: AppColors.armyGreen)),
                          const Text('OF APPRECIATION', style: TextStyle(fontSize: 16, letterSpacing: 4, color: AppColors.saffron)),
                          const SizedBox(height: 40),
                          const Text('This is proudly presented to', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16)),
                          const SizedBox(height: 16),
                          Text(widget.user.name.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: AppColors.armyGreen, color: Colors.black87)),
                          const SizedBox(height: 16),
                          Text('For their generous contribution of ₹$amount towards the "$campaignName".', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Container(width: 100, height: 1, color: Colors.black54, margin: const EdgeInsets.only(top: 4, bottom: 4)),
                                  const Text('Date Donated', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Army Trust', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'cursive', fontSize: 18, color: AppColors.armyGreen)),
                                  Container(width: 100, height: 1, color: Colors.black54, margin: const EdgeInsets.only(top: 4, bottom: 4)),
                                  const Text('Official Signature', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fade(duration: 600.ms).scale(curve: Curves.easeOutBack, begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 40),
            _buildShareButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _isSharing ? null : _shareCertificate,
        icon: _isSharing 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.share),
        label: Text(_isSharing ? 'Preparing Image...' : 'Share This Certificate', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.armyGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ).animate().fade(delay: 500.ms).slideY(begin: 0.5);
  }
}
