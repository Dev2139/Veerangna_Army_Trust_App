class WalletTransaction {
  final String id;
  final String type; // 'credit' or 'debit'
  final double amount;
  final String description;
  final String? cashfreeOrderId;
  final String? cashfreePaymentId;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final Map<String, dynamic>? campaign;
  final String? createdAt;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    this.cashfreeOrderId,
    this.cashfreePaymentId,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.campaign,
    this.createdAt,
  });

  bool get isCredit => type == 'credit';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['_id'] ?? '',
      type: json['type'] ?? 'credit',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      cashfreeOrderId: json['cashfree_order_id'] ?? json['razorpay_order_id'],
      cashfreePaymentId: json['cashfree_payment_id'] ?? json['razorpay_payment_id'],
      razorpayOrderId: json['razorpay_order_id'],
      razorpayPaymentId: json['razorpay_payment_id'],
      campaign: json['campaign'] is Map ? Map<String, dynamic>.from(json['campaign']) : null,
      createdAt: json['createdAt'],
    );
  }
}

class WalletModel {
  final String id;
  final String userId;
  final double balance;
  final List<WalletTransaction> transactions;
  final String? createdAt;

  WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    required this.transactions,
    this.createdAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final txList = (json['transactions'] as List<dynamic>? ?? [])
        .map((tx) => WalletTransaction.fromJson(tx as Map<String, dynamic>))
        .toList()
        .reversed
        .toList(); // newest first

    return WalletModel(
      id: json['_id'] ?? '',
      userId: json['user'] is String ? json['user'] : (json['user']?['_id'] ?? ''),
      balance: (json['balance'] ?? 0).toDouble(),
      transactions: txList,
      createdAt: json['createdAt'],
    );
  }
}
