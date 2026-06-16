class NewsModel {
  final String id;
  final String title;
  final String content;
  final String type;
  final int likesCount;
  final String? mediaUrl;
  final DateTime createdAt;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.likesCount,
    this.mediaUrl,
    required this.createdAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'news',
      likesCount: json['likesCount'] ?? 0,
      mediaUrl: json['mediaUrl'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
