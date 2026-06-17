class BillingInfo {
  final String firstName;
  final String lastName;
  final String street1;
  final String street2;
  final String street3;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String panCard;
  final String howHeard;
  final bool keepUpdated;
  final bool donateAnonymously;

  BillingInfo({
    this.firstName = '',
    this.lastName = '',
    this.street1 = '',
    this.street2 = '',
    this.street3 = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.country = '',
    this.panCard = '',
    this.howHeard = '',
    this.keepUpdated = true,
    this.donateAnonymously = false,
  });

  factory BillingInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BillingInfo();
    return BillingInfo(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      street1: json['street1'] ?? '',
      street2: json['street2'] ?? '',
      street3: json['street3'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? '',
      panCard: json['panCard'] ?? '',
      howHeard: json['howHeard'] ?? '',
      keepUpdated: json['keepUpdated'] ?? true,
      donateAnonymously: json['donateAnonymously'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'street1': street1,
      'street2': street2,
      'street3': street3,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'panCard': panCard,
      'howHeard': howHeard,
      'keepUpdated': keepUpdated,
      'donateAnonymously': donateAnonymously,
    };
  }
}

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
  final BillingInfo billingInfo;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.savedCampaigns,
    required this.eventParticipation,
    required this.billingInfo,
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
      billingInfo: BillingInfo.fromJson(json['billingInfo']),
      createdAt: json['createdAt'],
      totalDonated: (json['totalDonated'] ?? 0).toDouble(),
      donationHistory: json['donationHistory'] ?? [],
    );
  }
}
