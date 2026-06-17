import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/widgets/glassy_container.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue.withOpacity(0.65),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
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
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];
              final isEvent = item.type == 'event';

              return GlassyContainer(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.white,
                opacity: 0.08,
                borderRadius: BorderRadius.circular(16),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isEvent ? AppColors.saffron.withOpacity(0.2) : AppColors.primaryBlue.withOpacity(0.2),
                    child: Icon(
                      isEvent ? Icons.event : Icons.newspaper,
                      color: isEvent ? AppColors.saffron : AppColors.primaryBlue,
                    ),
                  ),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDarkBlue)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('MMM d, yyyy • h:mm a').format(item.date),
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(reverse: true),
                delay: (index * 120).ms,
              ).slideY(
                begin: 0,
                end: -0.015,
                duration: (2000 + (index * 150)).ms,
                curve: Curves.easeInOut,
              );
            },
          );
        },
      ),
    );
  }
}
