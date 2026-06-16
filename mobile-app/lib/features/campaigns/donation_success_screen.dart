import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';

class DonationSuccessScreen extends StatefulWidget {
  final String campaignTitle;
  final double amount;

  const DonationSuccessScreen({Key? key, required this.campaignTitle, required this.amount}) : super(key: key);

  @override
  State<DonationSuccessScreen> createState() => _DonationSuccessScreenState();
}

class _DonationSuccessScreenState extends State<DonationSuccessScreen> {
  late ConfettiController _confettiController;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _shareDonation() async {
    setState(() => _isSharing = true);
    try {
      final Uint8List? image = await _screenshotController.capture();
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('\${directory.path}/donation_share.png').create();
        await imagePath.writeAsBytes(image);
        
        await Share.shareXFiles(
          [XFile(imagePath.path)], 
          text: 'I just donated ₹\${widget.amount} to support the \${widget.campaignTitle} via the Army Trust App! Join me in making a difference. 🇮🇳',
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Donation Successful', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.armyGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.check_circle, color: Colors.green, size: 80)
                    .animate()
                    .scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                const Text(
                  'Thank You!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.armyGreen),
                ).animate().fade(delay: 300.ms).slideY(begin: 0.5),
                const SizedBox(height: 12),
                Text(
                  'Your generous contribution of ₹\${widget.amount} helps us support the real heroes of our nation.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ).animate().fade(delay: 500.ms),
                const SizedBox(height: 40),
                
                // Shareable Card
                Screenshot(
                  controller: _screenshotController,
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Colors.orange.shade50, Colors.green.shade50],
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.shield, color: AppColors.saffron, size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            'PROUD SUPPORTER',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2, color: AppColors.armyGreen),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.campaignTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.armyGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'I made a difference today. 🇮🇳',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.armyGreen),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fade(delay: 800.ms).scale(curve: Curves.easeOutBack),
                
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _isSharing ? null : _shareDonation,
                    icon: _isSharing 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.share),
                    label: Text(_isSharing ? 'Preparing...' : 'Share My Support', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.saffron,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ).animate().fade(delay: 1000.ms).slideY(begin: 0.5),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.orange, Colors.white, Colors.blue],
            ),
          ),
        ],
      ),
    );
  }
}
