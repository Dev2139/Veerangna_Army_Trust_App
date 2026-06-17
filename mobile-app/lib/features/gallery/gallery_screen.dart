import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/api_service.dart';
import '../../data/models/gallery_model.dart';
import '../../core/widgets/glassy_container.dart';
import '../../core/widgets/glassy_background.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<GalleryModel>> _galleryFuture;

  @override
  void initState() {
    super.initState();
    _galleryFuture = _apiService.getGallery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Media Gallery', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
        child: FutureBuilder<List<GalleryModel>>(
          future: _galleryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Failed to load gallery'));
            }

            final images = snapshot.data ?? [];

            if (images.isEmpty) {
              return const Center(child: Text('No images in the gallery yet.'));
            }

            return GridView.builder(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 80),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final img = images[index];
                return GlassyContainer(
                  color: Colors.white,
                  opacity: 0.05,
                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.all(4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          img.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              Container(color: Colors.white.withOpacity(0.05), child: const Icon(Icons.image, color: Colors.grey)),
                        ),
                        if (img.caption.isNotEmpty)
                          Positioned(
                            bottom: 4,
                            left: 4,
                            right: 4,
                            child: GlassyContainer(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              borderRadius: BorderRadius.circular(8),
                              opacity: 0.25,
                              blur: 8.0,
                              border: Border.all(color: Colors.white.withOpacity(0.15)),
                              child: Text(
                                img.caption,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, shadows: [
                                  Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2),
                                ]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ).animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                  delay: (index * 120).ms,
                ).slideY(
                  begin: 0,
                  end: -0.02,
                  duration: (2000 + (index * 150)).ms,
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
