class BannerModel {
  final String id;
  final String? title;
  final String imageUrl;
  final String? targetUrl;
  final bool isActive;

  BannerModel({
    required this.id,
    this.title,
    required this.imageUrl,
    this.targetUrl,
    required this.isActive,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id'] ?? '',
      title: json['title'],
      imageUrl: json['imageUrl'] ?? '',
      targetUrl: json['targetUrl'],
      isActive: json['isActive'] ?? true,
    );
  }
}
