import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/api_service.dart';
import '../../data/models/news_model.dart';
import '../../core/widgets/glassy_container.dart';
import '../../core/widgets/glassy_background.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({Key? key}) : super(key: key);

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<NewsModel>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _apiService.getNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Updates & News', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue.withOpacity(0.65),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: GlassyBackground(
        child: FutureBuilder<List<NewsModel>>(
          future: _newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Failed to load news'));
            }

            final newsList = snapshot.data ?? [];

            if (newsList.isEmpty) {
              return const Center(child: Text('No news updates available.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final news = newsList[index];
                return GlassyContainer(
                  margin: const EdgeInsets.only(bottom: 20),
                  color: Colors.white,
                  opacity: 0.08,
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (news.mediaUrl != null && news.mediaUrl!.isNotEmpty)
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            image: DecorationImage(
                              image: NetworkImage(news.mediaUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: const Center(child: Icon(Icons.newspaper, size: 48, color: Colors.grey)),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: news.type == 'motivational' ? AppColors.saffron.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: news.type == 'motivational' ? AppColors.saffron.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
                                  ),
                                  child: Text(
                                    news.type.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: news.type == 'motivational' ? Colors.orange[800] : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              news.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDarkBlue),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              news.content,
                              style: const TextStyle(color: Colors.black87),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.thumb_up_alt_outlined, size: 20, color: AppColors.primaryBlue),
                                    const SizedBox(width: 8),
                                    Text('${news.likesCount}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDarkBlue)),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share, color: Colors.grey),
                                  onPressed: () {},
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ).animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                  delay: (index * 150).ms,
                ).slideY(
                  begin: 0,
                  end: -0.015,
                  duration: (2200 + (index * 200)).ms,
                  curve: Curves.easeInOut,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
