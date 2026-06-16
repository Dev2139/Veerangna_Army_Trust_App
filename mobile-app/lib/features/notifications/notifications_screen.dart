import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/api_service.dart';
import '../../data/models/event_model.dart';
import '../../data/models/news_model.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String type; // 'event' or 'news'

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<NotificationItem>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _loadNotifications();
  }

  Future<List<NotificationItem>> _loadNotifications() async {
    final events = await _apiService.getEvents();
    final news = await _apiService.getNews();

    List<NotificationItem> items = [];

    for (var e in events) {
      items.add(NotificationItem(
        id: e.id,
        title: 'New Event: ${e.title}',
        description: e.description,
        date: e.date,
        type: 'event',
      ));
    }

    for (var n in news) {
      items.add(NotificationItem(
        id: n.id,
        title: 'News: ${n.title}',
        description: n.content,
        date: n.createdAt,
        type: 'news',
      ));
    }

    // Sort newest first
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 80,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.armyGreen,
        elevation: 0,
      ),
      body: FutureBuilder<List<NotificationItem>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeleton();
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load notifications'));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications yet.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];
              final isEvent = item.type == 'event';

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isEvent ? AppColors.saffron.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                    child: Icon(
                      isEvent ? Icons.event : Icons.newspaper,
                      color: isEvent ? AppColors.saffron : Colors.blue,
                    ),
                  ),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('MMM d, yyyy • h:mm a').format(item.date),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
