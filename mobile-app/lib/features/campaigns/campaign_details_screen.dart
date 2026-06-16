import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../core/theme/app_colors.dart';
import 'donation_success_screen.dart';
import '../../data/services/api_service.dart';

class CampaignDetailsScreen extends StatefulWidget {
  final String campaignId;
  final String title;
  final double collected;
  final double required;
  final String imageUrl;

  const CampaignDetailsScreen({
    Key? key,
    required this.campaignId,
    required this.title,
    required this.collected,
    required this.required,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<CampaignDetailsScreen> createState() => _CampaignDetailsScreenState();
}

class _CampaignDetailsScreenState extends State<CampaignDetailsScreen> {
  late Razorpay _razorpay;
  final ApiService _apiService = ApiService();
  double _selectedAmount = 500;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Verify payment on backend
    bool isVerified = await _apiService.verifyPayment(
      response.orderId ?? '',
      response.paymentId ?? '',
      response.signature ?? '',
      widget.campaignId,
      _selectedAmount,
    );

    setState(() => _isProcessing = false);

    if (isVerified) {
      if (!mounted) return;
      Navigator.pop(context); // Close bottom sheet
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DonationSuccessScreen(
            campaignTitle: widget.title,
            amount: _selectedAmount,
          ),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment verification failed'), backgroundColor: Colors.red),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}'), backgroundColor: Colors.red),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('External Wallet Selected')),
    );
  }

  void _startPaymentProcess(StateSetter setModalState) async {
    setModalState(() => _isProcessing = true);

    // 1. Create order on backend
    String? orderId = await _apiService.createRazorpayOrder(widget.campaignId, _selectedAmount);

    if (orderId == null) {
      setModalState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not initiate payment. Try again.'), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. Open Razorpay Checkout
    var options = {
      'key': 'rzp_test_T1pupuewW0vIvQ', // Test Key
      'amount': (_selectedAmount * 100).toInt(),
      'name': 'Army Trust',
      'order_id': orderId,
      'description': 'Donation for ${widget.title}',
      'timeout': 120, // in seconds
      'prefill': {
        'contact': '9876543210',
        'email': 'test@razorpay.com'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setModalState(() => _isProcessing = false);
      print('Razorpay Error: $e');
    }
  }

  void _showDonationBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Amount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [100, 500, 1000, 5000].map((amount) {
                      bool isSelected = _selectedAmount == amount;
                      return ChoiceChip(
                        label: Text('₹$amount', style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                        selected: isSelected,
                        selectedColor: AppColors.armyGreen,
                        onSelected: (selected) {
                          if (selected) setModalState(() => _selectedAmount = amount.toDouble());
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : () => _startPaymentProcess(setModalState),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.saffron,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isProcessing
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Pay ₹${_selectedAmount.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = widget.required > 0 ? widget.collected / widget.required : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.armyGreen,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: widget.imageUrl.isNotEmpty ? DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ) : null,
              ),
              child: widget.imageUrl.isEmpty ? const Center(child: Icon(Icons.image, size: 64, color: Colors.grey)) : null,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'We are raising funds to support the families of our brave martyrs. Your contribution will directly impact their lives, providing them with necessary financial support, education for their children, and medical assistance.',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Donation Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 12,
                    backgroundColor: Colors.grey[200],
                    color: AppColors.saffron,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹ ${widget.collected.toStringAsFixed(0)} raised', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.armyGreen)),
                      Text('Goal: ₹ ${widget.required.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: ElevatedButton(
          onPressed: _showDonationBottomSheet,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.saffron,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Donate Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ).animate().scale(delay: 400.ms, duration: 300.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}
