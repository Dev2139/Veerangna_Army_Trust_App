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
            transactionId: response.paymentId,
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DefaultTabController(
          length: 2,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Make a Donation',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDarkBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tab Bar
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: AppColors.textSecondary,
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                        tabs: const [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.credit_card, size: 16),
                                SizedBox(width: 6),
                                Text('Pay Online'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.account_balance_wallet, size: 16),
                                SizedBox(width: 6),
                                Text('Wallet'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Tab Views
                    SizedBox(
                      height: 230,
                      child: TabBarView(
                        children: [
                          // ── Tab 1: Razorpay ──
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Select Amount',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [100, 500, 1000, 5000].map((amount) {
                                    bool isSelected = _selectedAmount == amount;
                                    return GestureDetector(
                                      onTap: () => setModalState(
                                          () => _selectedAmount = amount.toDouble()),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primaryBlue
                                              : AppColors.lightBlue,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '₹$amount',
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.textDarkBlue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isProcessing
                                        ? null
                                        : () => _startPaymentProcess(setModalState),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14)),
                                      elevation: 0,
                                    ),
                                    child: _isProcessing
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                                color: Colors.white, strokeWidth: 2))
                                        : Text(
                                            'Pay ₹${_selectedAmount.toInt()} via Razorpay',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── Tab 2: Wallet ──
                          FutureBuilder<dynamic>(
                            future: _apiService.getWallet(),
                            builder: (context, walletSnap) {
                              final walletBalance = walletSnap.data?.balance ?? 0.0;
                              final isLoading = walletSnap.connectionState ==
                                  ConnectionState.waiting;
                              final hasEnough = walletBalance >= _selectedAmount;

                              return Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Wallet Balance pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF2A64B5),
                                            Color(0xFF228B22),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.account_balance_wallet,
                                              color: Colors.white,
                                              size: 20),
                                          const SizedBox(width: 10),
                                          Text(
                                            isLoading
                                                ? 'Loading...'
                                                : 'Balance: ₹${walletBalance.toInt()}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text('Select Amount',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary)),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 8,
                                      children: [100, 500, 1000, 5000].map((amount) {
                                        bool isSelected = _selectedAmount == amount;
                                        return GestureDetector(
                                          onTap: () => setModalState(
                                              () => _selectedAmount = amount.toDouble()),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.armyGreen
                                                  : AppColors.lightBlue,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '₹$amount',
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : AppColors.textDarkBlue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const Spacer(),
                                    if (!hasEnough && !isLoading)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            Icon(Icons.warning_amber_rounded,
                                                color: Colors.orange.shade700,
                                                size: 16),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Insufficient balance. Add money to wallet first.',
                                              style: TextStyle(
                                                  color: Colors.orange.shade700,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: (_isProcessing ||
                                                !hasEnough ||
                                                isLoading)
                                            ? null
                                            : () => _donateFromWallet(
                                                setModalState, context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.armyGreen,
                                          disabledBackgroundColor:
                                              Colors.grey.shade300,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14)),
                                          elevation: 0,
                                        ),
                                        child: _isProcessing
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2))
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                      Icons.volunteer_activism,
                                                      color: Colors.white,
                                                      size: 18),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Donate ₹${_selectedAmount.toInt()} from Wallet',
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _donateFromWallet(
      StateSetter setModalState, BuildContext sheetContext) async {
    setModalState(() => _isProcessing = true);

    final result =
        await _apiService.donateFromWallet(widget.campaignId, _selectedAmount);

    setModalState(() => _isProcessing = false);

    if (result != null && result['success'] == true) {
      if (!mounted) return;
      Navigator.pop(sheetContext); // close bottom sheet
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DonationSuccessScreen(
            campaignTitle: widget.title,
            amount: _selectedAmount,
            transactionId: 'Wallet Transaction',
          ),
        ),
      );
    } else {
      if (!mounted) return;
      final errMsg = result?['error'] ?? 'Donation failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errMsg),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    double progress = widget.required > 0 ? widget.collected / widget.required : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primaryBlue,
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
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹ ${widget.collected.toStringAsFixed(0)} raised', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
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
            backgroundColor: AppColors.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Donate Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ).animate().scale(delay: 400.ms, duration: 300.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}
