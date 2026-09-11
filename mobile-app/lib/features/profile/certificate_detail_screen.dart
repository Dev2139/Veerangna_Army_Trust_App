import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glassy_background.dart';
import '../../data/models/user_model.dart';

class CertificateDetailScreen extends StatefulWidget {
  final UserModel user;
  final dynamic donation; // Null for Membership, dynamic Map for Donation Receipt
  final String joinedDate;

  const CertificateDetailScreen({
    Key? key,
    required this.user,
    this.donation,
    required this.joinedDate,
  }) : super(key: key);

  @override
  State<CertificateDetailScreen> createState() => _CertificateDetailScreenState();
}

class _CertificateDetailScreenState extends State<CertificateDetailScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSaving = false;
  bool _isSharing = false;

  Future<void> _shareCertificate() async {
    setState(() => _isSharing = true);
    try {
      final Uint8List? image = await _screenshotController.capture(pixelRatio: 3.0);
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/veerangna_share_certificate.png').create();
        await imagePath.writeAsBytes(image);
        
        final isDonation = widget.donation != null;
        final shareText = isDonation
            ? 'I am proud to support the brave soldiers of our nation via the Veerangna App! Here is my donation certificate. 🇮🇳'
            : 'I am proud to be a registered member of the Veerangna Trust! Join me. 🇮🇳';

        await Share.shareXFiles(
          [XFile(imagePath.path)], 
          text: shareText,
        );
      }
    } catch (e) {
      debugPrint('Error sharing: $e');
    } finally {
      setState(() => _isSharing = false);
    }
  }

  Future<void> _downloadAsPdf() async {
    setState(() => _isSaving = true);
    try {
      final Uint8List? imageBytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (imageBytes != null) {
        final pdf = pw.Document();
        final pdfImage = pw.MemoryImage(imageBytes);
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
              );
            },
          ),
        );

        final directory = await getApplicationDocumentsDirectory();
        final isDonation = widget.donation != null;
        final docName = isDonation
            ? 'Veerangna_Donation_Receipt_${widget.donation['_id'] ?? widget.donation['id'] ?? "3281"}.pdf'
            : 'Veerangna_Membership_Certificate_${widget.user.id}.pdf';
        
        final file = await File('${directory.path}/$docName').create();
        await file.writeAsBytes(await pdf.save());

        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('PDF Download Successful'),
              content: Text('Your PDF certificate has been successfully saved to your documents folder:\n\n${file.path}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _shareCertificate();
                  },
                  child: const Text('Share Instead'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save PDF: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
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
    final isDonation = widget.donation != null;
    final title = isDonation ? 'Donation Certificate' : 'Membership Certificate';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue.withOpacity(0.65),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GlassyBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Screenshot(
                  controller: _screenshotController,
                  child: isDonation 
                      ? _buildDonationReceiptCertificate() 
                      : _buildMembershipCertificate(),
                ),
                
                const SizedBox(height: 32),
                
                // Action Buttons: Download PDF and Share Image
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _downloadAsPdf,
                          icon: _isSaving 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
                          label: Text(_isSaving ? 'Saving PDF...' : 'Download PDF', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
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
                          onPressed: _isSharing ? null : _shareCertificate,
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
                ).animate().fade(delay: 200.ms),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMembershipCertificate() {
    return Container(
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
            child: Icon(Icons.shield, size: 200, color: AppColors.primaryBlue.withOpacity(0.05)),
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
                const Icon(Icons.shield, color: AppColors.primaryBlue, size: 60),
                const SizedBox(height: 20),
                const Text('CERTIFICATE', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 8, color: AppColors.primaryBlue)),
                const Text('OF MEMBERSHIP', style: TextStyle(fontSize: 16, letterSpacing: 4, color: AppColors.saffron)),
                const SizedBox(height: 40),
                const Text('This is to certify that', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16)),
                const SizedBox(height: 16),
                Text(widget.user.name.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: AppColors.primaryBlue, color: Colors.black87)),
                const SizedBox(height: 16),
                const Text('has officially joined the Veerangna Trust community and pledged to support the brave soldiers of our nation.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, height: 1.5)),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.joinedDate, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13)),
                        Container(width: 100, height: 1, color: Colors.black54, margin: const EdgeInsets.only(top: 4, bottom: 4)),
                        const Text('Date Joined', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Veerangna', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'cursive', fontSize: 18, color: AppColors.primaryBlue)),
                        Container(width: 100, height: 1, color: Colors.black54, margin: const EdgeInsets.only(top: 4, bottom: 4)),
                        const Text('Official Signature', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 600.ms).scale(curve: Curves.easeOutBack, begin: const Offset(0.9, 0.9));
  }

  Widget _buildDonationReceiptCertificate() {
    final amount = (widget.donation['amount'] ?? 0).toDouble();
    final rawDate = widget.donation['createdAt'];
    final formattedDate = rawDate != null 
        ? DateFormat('dd-MM-yyyy').format(DateTime.parse(rawDate)) 
        : DateFormat('dd-MM-yyyy').format(DateTime.now());
    
    final txId = widget.donation['_id'] ?? widget.donation['id'] ?? 'pay_HISTORIC';
    final amountWords = amountToWords(amount);

    return Container(
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
              _buildTableRow('Name', widget.user.name.toUpperCase()),
              _buildTableRow('PAN No.', '-'),
              _buildTableRow('Email', widget.user.email),
              _buildTableRow('Address', 'GUJARAT'),
              _buildTableRow('Mobile No.', widget.user.phone),
              _buildTableRow('Amount', 'Rs. $amount ($amountWords)'),
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
    ).animate().fade(duration: 600.ms).scale(curve: Curves.easeOutBack, begin: const Offset(0.9, 0.9));
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
