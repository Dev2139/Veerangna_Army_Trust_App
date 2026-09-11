import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/api_service.dart';
import '../../data/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationSuccessScreen extends StatefulWidget {
  final String campaignTitle;
  final double amount;
  final String? transactionId;

  const DonationSuccessScreen({
    Key? key,
    required this.campaignTitle,
    required this.amount,
    this.transactionId,
  }) : super(key: key);

  @override
  State<DonationSuccessScreen> createState() => _DonationSuccessScreenState();
}

class _DonationSuccessScreenState extends State<DonationSuccessScreen> {
  late ConfettiController _confettiController;
  final ScreenshotController _screenshotController = ScreenshotController();
  final ApiService _apiService = ApiService();
  
  UserModel? _user;
  bool _isLoadingUser = true;
  bool _isSharing = false;
  bool _isDownloading = false;

  final TextEditingController _panController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _panController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadUserProfile() async {
    try {
      final user = await _apiService.getUserProfile();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoadingUser = false;
          if (user != null) {
            final info = user.billingInfo;
            if (info.panCard.isNotEmpty) {
              _panController.text = info.panCard;
            }
            final addressParts = [
              info.street1,
              info.street2,
              info.street3,
              info.city,
              info.state,
              info.zipCode,
              info.country
            ].where((p) => p.isNotEmpty).toList();
            if (addressParts.isNotEmpty) {
              _addressController.text = addressParts.join(', ');
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  void _sendToWhatsApp() async {
    final txId = widget.transactionId ?? 'pay_RCHB14312309';
    final formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final amountWords = amountToWords(widget.amount);
    
    final donorName = (_isLoadingUser ? 'Guest Donor' : (_user?.name ?? 'Guest Donor')).toUpperCase();
    final addressText = _addressController.text.isNotEmpty ? _addressController.text.toUpperCase() : 'GUJARAT';
    final panText = _panController.text.isNotEmpty ? _panController.text.toUpperCase() : 'NOT PROVIDED';
    final emailText = _user?.email ?? 'N/A';
    final phoneText = _user?.phone ?? 'N/A';

    final textMessage = 
      "🇮🇳 *Veerangna Army Trust (Regd.)* 🇮🇳\n"
      "*Official Donation Receipt*\n\n"
      "Dear *${donorName}*,\n"
      "Thank you for your noble support towards our heroes. Your contribution has been received successfully!\n\n"
      "• *Receipt No:* VEER/2026-27/TX-${txId.length > 6 ? txId.substring(txId.length - 6).toUpperCase() : '3281'}\n"
      "• *Campaign Name:* ${widget.campaignTitle}\n"
      "• *Amount Paid:* ₹${widget.amount} ($amountWords)\n"
      "• *Transaction ID:* $txId\n"
      "• *Date:* $formattedDate\n"
      "• *Payment Status:* Success (Cashfree)\n\n"
      "*Donor Details:*\n"
      "• *PAN Number:* $panText\n"
      "• *Mobile No:* $phoneText\n"
      "• *Email:* $emailText\n"
      "• *Billing Address:* $addressText\n\n"
      "*Veerangna Trust Information:*\n"
      "• *Reg. No:* F/21847/Ahmedabad\n"
      "• *Tax Exemption:* Section 80G(5)(vi)\n"
      "• *Contact:* +91 9173 827722\n\n"
      "Jai Hind! 🇮🇳";

    final whatsappUrl = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(textMessage)}");
    
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch WhatsApp.')),
          );
        }
      }
    } catch (e) {
      debugPrint('WhatsApp Launch Error: $e');
    }
  }

  Future<void> _shareDonation() async {
    setState(() => _isSharing = true);
    try {
      final Uint8List? image = await _screenshotController.capture(pixelRatio: 3.0);
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/veerangna_receipt.png').create();
        await imagePath.writeAsBytes(image);
        
        await Share.shareXFiles(
          [XFile(imagePath.path)], 
          text: 'I just donated ₹${widget.amount} to support "${widget.campaignTitle}" via the Veerangna App! Join me in making a difference. 🇮🇳',
        );
      }
    } catch (e) {
      debugPrint('Error sharing: $e');
    } finally {
      setState(() => _isSharing = false);
    }
  }

  Future<void> _downloadCertificate() async {
    setState(() => _isDownloading = true);
    try {
      final Uint8List? image = await _screenshotController.capture(pixelRatio: 3.0);
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'Veerangna_Receipt_${widget.transactionId ?? "3281"}.png';
        final file = await File('${directory.path}/$fileName').create();
        await file.writeAsBytes(image);
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Download Successful'),
              content: Text('Your certificate has been successfully saved to your documents folder:\n\n${file.path}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _shareDonation();
                  },
                  child: const Text('Share Instead'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error downloading: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  String amountToWords(double amount) {
    int number = amount.toInt();
    if (number == 0) return 'Zero Only';
    
    final units = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
      'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
    ];
    final tens = [
      '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
    ];
    
    String convert(int n) {
      if (n < 20) {
        return units[n];
      }
      if (n < 100) {
        return tens[n ~/ 10] + (n % 10 != 0 ? ' ' + units[n % 10] : '');
      }
      if (n < 1000) {
        return units[n ~/ 100] + ' Hundred' + (n % 100 != 0 ? ' and ' + convert(n % 100) : '');
      }
      if (n < 100000) {
        return convert(n ~/ 1000) + ' Thousand' + (n % 1000 != 0 ? ' ' + convert(n % 1000) : '');
      }
      if (n < 10000000) {
        return convert(n ~/ 100000) + ' Lakh' + (n % 100000 != 0 ? ' ' + convert(n % 100000) : '');
      }
      return convert(n ~/ 10000000) + ' Crore' + (n % 10000000 != 0 ? ' ' + convert(n % 10000000) : '');
    }
    
    return convert(number) + ' Only';
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final amountWords = amountToWords(widget.amount);
    final txId = widget.transactionId ?? 'pay_RCHB14312309';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Donation Successful', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 70)
                    .animate()
                    .scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 12),
                const Text(
                  'Thank You for Your Support!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your receipt has been generated. You can customize the details below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                
                // Detailed Receipt Screenshot Box
                Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.primaryBlue, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header: Logo & Trust details
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Circular Logo
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300, width: 1),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/logo.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Veerangna',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'PAN: ABETS5326G | 80G No: ABETS5326GFI2022101',
                                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.black54),
                                  ),
                                  const Text(
                                    'Email: info@veerangnaarmytrust.org | Web: www.veerangnaarmytrust.org',
                                    style: TextStyle(fontSize: 7, color: Colors.black54),
                                  ),
                                  const Text(
                                    'Contact: +91 9173 827722',
                                    style: TextStyle(fontSize: 7, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primaryBlue),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'DONATION CERTIFICATE',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 10),
                        Divider(color: Colors.grey.shade400, height: 1, thickness: 1),
                        const SizedBox(height: 6),
                        
                        // Receipt Meta
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Receipt No: VEER/2026-27/TX-${txId.length > 6 ? txId.substring(txId.length - 6).toUpperCase() : "3281"}',
                              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            Text(
                              'Date: $formattedDate',
                              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Details Grid
                        Table(
                          border: TableBorder.all(color: Colors.grey.shade300, width: 0.8),
                          columnWidths: const {
                            0: FlexColumnWidth(1.2),
                            1: FlexColumnWidth(2.0),
                          },
                          children: [
                            _buildTableRow('Name', (_isLoadingUser ? 'Loading...' : (_user?.name ?? 'Guest Donor')).toUpperCase()),
                            _buildTableRow('PAN No.', _panController.text.isNotEmpty ? _panController.text.toUpperCase() : '-'),
                            _buildTableRow('Email', _user?.email ?? '-'),
                            _buildTableRow('Address', _addressController.text.isNotEmpty ? _addressController.text.toUpperCase() : 'GUJARAT'),
                            _buildTableRow('Mobile No.', _user?.phone ?? '-'),
                            _buildTableRow('Amount', 'Rs. ${widget.amount} ($amountWords)'),
                            _buildTableRow('Financial Year', '2026-2027'),
                            _buildTableRow('Section', 'Section 80G(5)(vi)'),
                            _buildTableRow('Payment Mode', 'Online (UPI/Cashfree)'),
                            _buildTableRow('Transaction No.', txId),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Office Details
                        Table(
                          border: TableBorder.all(color: Colors.grey.shade300, width: 0.8),
                          columnWidths: const {
                            0: FlexColumnWidth(1.0),
                            1: FlexColumnWidth(2.2),
                          },
                          children: [
                            _buildOfficeRow('Office Address', '5th Floor, Kashmira Chambers, Old High Court Road, Navrangpura, Ahmedabad 380009.'),
                            _buildOfficeRow('Education Center', 'Rani Rahim Nagar, I P Mission Kabrastan, In Riverfront, Behrampura, Ahmedabad.'),
                            _buildOfficeRow('Old Age Home', '11/A, Ground Floor, Rangvarsha Society, Opp New Sharda Mandir, Ellisbridge Ahmedabad 380006.'),
                          ],
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Small Notes
                        Text(
                          'Notes: Please write your Cheque/DD in favour of "Veerangna Army Trust". This receipt is subject to acceptance and realisation of the donation amount. Tax exemption available under Section 80G of the Income Tax Act.\n\n'
                          'VEERANGNA ARMY TRUST is registered under the Charity Commissioner (Reg. No: F/21847/Ahmedabad). This is an acknowledgment of the donation received. VEERANGNA ARMY TRUST shall furnish the Consolidated Certificate of Donation for the financial year 2026-2027 in Form No. 10BE on or before May 31, 2027 as per sub-rule (5) & (6) of Rule 18AB of Income Tax Rules.',
                          style: const TextStyle(fontSize: 5.8, color: Colors.black54, height: 1.3),
                        ),
                        
                        const SizedBox(height: 14),
                        
                        // Signatures
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Tilting program seal
                            Transform.rotate(
                              angle: -0.1,
                              child: Container(
                                width: 65,
                                height: 65,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.blue.shade800.withOpacity(0.7), width: 1.8),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.blue.shade800.withOpacity(0.7), width: 0.8),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'VEERANGNA',
                                          style: TextStyle(
                                            fontSize: 5.5,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.blue.shade800.withOpacity(0.7),
                                          ),
                                        ),
                                        Text(
                                          'Reg. No.\nF/21847/Ahmd',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 4.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800.withOpacity(0.7),
                                          ),
                                        ),
                                        Text(
                                          'AHMEDABAD',
                                          style: TextStyle(
                                            fontSize: 5,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.blue.shade800.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            // Cursive Sig
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Veerangna Trust',
                                  style: TextStyle(
                                    fontFamily: 'cursive',
                                    fontSize: 16,
                                    color: Colors.blue.shade900.withOpacity(0.85),
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                Container(
                                  width: 90,
                                  height: 1,
                                  color: Colors.grey.shade400,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                ),
                                const Text(
                                  'Authorized Signature',
                                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(duration: 600.ms).scale(curve: Curves.easeOutBack, begin: const Offset(0.9, 0.9)),
                
                const SizedBox(height: 24),
                
                // Form customization inputs
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customize Certificate Details',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _panController,
                          maxLength: 10,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'PAN Number (for 80G tax benefit)',
                            hintText: 'ABCDE1234F',
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onChanged: (val) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _addressController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: 'Donor Address',
                            hintText: 'Enter your city or full address',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onChanged: (val) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(delay: 200.ms),
                
                const SizedBox(height: 24),

                // WhatsApp Button
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _sendToWhatsApp,
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text('Send Receipt on WhatsApp', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                  ),
                ).animate().fade(delay: 250.ms),
                
                const SizedBox(height: 12),
                
                // Action Buttons: Download and Share
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isDownloading ? null : _downloadCertificate,
                          icon: _isDownloading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.download_rounded, color: Colors.white),
                          label: Text(_isDownloading ? 'Downloading...' : 'Download', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isSharing ? null : _shareDonation,
                          icon: _isSharing 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.share_rounded, color: Colors.white),
                          label: Text(_isSharing ? 'Sharing...' : 'Share', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fade(delay: 300.ms),
                
                const SizedBox(height: 24),
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

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            value,
            style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  TableRow _buildOfficeRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Text(
            label,
            style: const TextStyle(fontSize: 6.5, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Text(
            value,
            style: const TextStyle(fontSize: 6.5, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
