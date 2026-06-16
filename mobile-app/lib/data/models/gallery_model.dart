class GalleryModel {
  final String id;
  final String imageUrl;
  final String caption;

  GalleryModel({
    required this.id,
    required this.imageUrl,
    required this.caption,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    return GalleryModel(
      id: json['_id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      caption: json['caption'] ?? '',
    );
  }
}
