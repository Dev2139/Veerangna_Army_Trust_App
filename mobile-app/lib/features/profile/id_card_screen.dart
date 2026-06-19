import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glassy_background.dart';
import '../../data/models/user_model.dart';

class IDCardScreen extends StatefulWidget {
  final UserModel user;

  const IDCardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<IDCardScreen> createState() => _IDCardScreenState();
}

class _IDCardScreenState extends State<IDCardScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isDownloadingImage = false;
  bool _isDownloadingPdf = false;
  bool _isSharing = false;

  Future<void> _downloadImage() async {
    setState(() => _isDownloadingImage = true);
    try {
      final Uint8List? imageBytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (imageBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'Veerangna_ID_Card_${widget.user.id.substring(widget.user.id.length - 6).toUpperCase()}.png';
        final file = await File('${directory.path}/$fileName').create();
        await file.writeAsBytes(imageBytes);

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Download Successful'),
              content: Text('Your ID Card image has been saved to:\n\n${file.path}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error downloading image: $e');
    } finally {
      setState(() => _isDownloadingImage = false);
    }
  }

  Future<void> _downloadPdf() async {
    setState(() => _isDownloadingPdf = true);
    try {
      final Uint8List? imageBytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (imageBytes != null) {
        final pdf = pw.Document();
        final image = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Container(
                  width: PdfPageFormat.a4.width * 0.7,
                  child: pw.Image(image),
                ),
              );
            },
          ),
        );

        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'Veerangna_ID_Card_${widget.user.id.substring(widget.user.id.length - 6).toUpperCase()}.pdf';
        final file = await File('${directory.path}/$fileName').create();
        await file.writeAsBytes(await pdf.save());

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Download Successful'),
              content: Text('Your ID Card PDF has been saved to:\n\n${file.path}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
    } finally {
      setState(() => _isDownloadingPdf = false);
    }
  }

  Future<void> _printOrShare() async {
    setState(() => _isSharing = true);
    try {
      final Uint8List? imageBytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final file = await File('${directory.path}/Veerangna_ID_Card.png').create();
        await file.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Check out my official Veerangna Army Trust Donor ID Card! 🇮🇳',
        );
      }
    } catch (e) {
      debugPrint('Error sharing/printing: $e');
    } finally {
      setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final idNo = "ID-${user.id.substring(user.id.length - 8).toUpperCase()}";
    final email = user.email;
    final mobile = user.phone;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My ID Card', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: GlassyBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                // Action Buttons Row (Print, Download PDF, Download Image)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSharing ? null : _printOrShare,
                        icon: const Icon(Icons.print, size: 16, color: Colors.white),
                        label: const Text('Print / Share', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isDownloadingPdf ? null : _downloadPdf,
                        icon: const Icon(Icons.picture_as_pdf, size: 16, color: Colors.white),
                        label: const Text('Download PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isDownloadingImage ? null : _downloadImage,
                        icon: const Icon(Icons.image, size: 16, color: Colors.white),
                        label: const Text('Download Image', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Card Screenshot Box
                Center(
                  child: Screenshot(
                    controller: _screenshotController,
                    child: Container(
                      width: 330,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade600, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Section with Green Gradient
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade700,
                                  Colors.green.shade500,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Logo
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/logo.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Trust name
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'LATE CHAMPABEN MADHAVJIBHAI RATANSHIBHAI CHARITABLE TRUST',
                                        style: TextStyle(
                                          fontSize: 7.8,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'CHARITY & SOCIAL WORKS',
                                        style: TextStyle(
                                          fontSize: 6.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white70,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Yellow Highlight Line
                          Container(
                            height: 4,
                            color: Colors.amber.shade600,
                          ),

                          const SizedBox(height: 18),

                          // Profile Photo
                          Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade600, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: (user.profilePhotoUrl != null && user.profilePhotoUrl!.isNotEmpty)
                                    ? Image.network(
                                        user.profilePhotoUrl!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            _buildInitialsAvatar(user),
                                      )
                                    : _buildInitialsAvatar(user),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // User Name
                          Center(
                            child: Text(
                              user.name.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Saffron Capsule
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade800,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Text(
                                'DONOR',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Info Table
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(0.8),
                                  1: FlexColumnWidth(2.0),
                                },
                                children: [
                                  _buildInfoRow('Id No.', idNo),
                                  _buildInfoRow('Email', email),
                                  _buildInfoRow('Mob.', mobile),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Footer Info Address
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Column(
                              children: [
                                Text(
                                  'H.O Khasra No 85 1st Floor Village Budh Pur Rija Pur North West -110036, Delhi',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 6.8,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Www.Champaben-Madhavjibhai-R-Thakkar-Charitable-Trustfoundation.in',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 6.5,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade300,
            Colors.blue.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  TableRow _buildInfoRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
