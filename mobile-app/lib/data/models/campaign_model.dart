class CampaignModel {
  final String id;
  final String title;
  final String description;
  final double amountRequired;
  final double amountCollected;
  final String status;
  final List<String> images;

  CampaignModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amountRequired,
    required this.amountCollected,
    required this.status,
    required this.images,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      amountRequired: (json['amountRequired'] ?? 0).toDouble(),
      amountCollected: (json['amountCollected'] ?? 0).toDouble(),
      status: json['status'] ?? 'active',
      images: List<String>.from(json['images'] ?? []),
    );
  }
}
