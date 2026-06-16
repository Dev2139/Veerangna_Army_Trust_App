class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<dynamic> savedCampaigns;
  final List<dynamic> eventParticipation;
  final String? createdAt;
  final double totalDonated;
  final List<dynamic> donationHistory;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.savedCampaigns,
    required this.eventParticipation,
    this.createdAt,
    this.totalDonated = 0.0,
    this.donationHistory = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown User',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      savedCampaigns: json['savedCampaigns'] ?? [],
      eventParticipation: json['eventParticipation'] ?? [],
      createdAt: json['createdAt'],
      totalDonated: (json['totalDonated'] ?? 0).toDouble(),
      donationHistory: json['donationHistory'] ?? [],
    );
  }
}
