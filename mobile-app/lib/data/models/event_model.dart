class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final List<dynamic> banners;
  final List<dynamic> registrations;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.banners,
    required this.registrations,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      location: json['location'] ?? '',
      banners: json['banners'] ?? [],
      registrations: json['registrations'] ?? [],
    );
  }
}
