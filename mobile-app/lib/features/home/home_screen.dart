import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/api_service.dart';
import '../../data/models/campaign_model.dart';
import '../campaigns/campaign_details_screen.dart';
import '../news/news_feed_screen.dart';
import '../profile/profile_screen.dart';
import '../events/events_screen.dart';
import '../gallery/gallery_screen.dart';
import '../about/about_screen.dart';
import '../faq/faq_screen.dart';
import '../food_donate/food_donate_screen.dart';
import '../notifications/notifications_screen.dart';
import '../account_details/account_details_screen.dart';
import '../legal_documents/legal_documents_screen.dart';
import '../../data/models/banner_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/widgets/glassy_container.dart';
import '../../core/widgets/glassy_background.dart';
import '../../core/widgets/autoplay_video_player.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _unreadCount = 0;
  List<String> _seenIds = [];
  final ApiService _apiService = ApiService();

  List<Widget> get _screens => [
    const HomeView(),
    const FaqScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkNotifications();
  }

  Future<void> _checkNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    _seenIds = prefs.getStringList('seen_notifications') ?? [];

    final events = await _apiService.getEvents();
    final news = await _apiService.getNews();

    int unread = 0;
    for (var e in events) {
      if (!_seenIds.contains(e.id)) unread++;
    }
    for (var n in news) {
      if (!_seenIds.contains(n.id)) unread++;
    }

    if (mounted) {
      setState(() {
        _unreadCount = unread;
      });
    }
  }

  Future<void> _markAllAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final events = await _apiService.getEvents();
    final news = await _apiService.getNews();

    for (var e in events) {
      if (!_seenIds.contains(e.id)) _seenIds.add(e.id);
    }
    for (var n in news) {
      if (!_seenIds.contains(n.id)) _seenIds.add(n.id);
    }

    await prefs.setStringList('seen_notifications', _seenIds);
    if (mounted) {
      setState(() {
        _unreadCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassyBackground(
        child: _screens[_currentIndex],
      ),
      extendBody: true,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: BottomNavigationBar(
            backgroundColor: Colors.white.withOpacity(0.65),
            elevation: 0,
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 2) {
                _markAllAsSeen();
              }
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: AppColors.primaryBlue,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              const BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: 'FAQ'),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications),
                    if (_unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                        ),
                      ),
                  ],
                ),
                label: 'Notifications',
              ),
              const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ApiService _apiService = ApiService();
  late Future<List<CampaignModel>> _campaignsFuture;
  late Future<List<BannerModel>> _bannersFuture;

  @override
  void initState() {
    super.initState();
    _campaignsFuture = _apiService.getCampaigns();
    _bannersFuture = _apiService.getBanners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network('https://res.cloudinary.com/dsddldquo/image/upload/v1781593109/tsrwudiwazhmwm78oa4g.jpg', height: 32, width: 32, fit: BoxFit.cover),
            ),
            const SizedBox(width: 8),
            const Text('Army Trust', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        backgroundColor: AppColors.primaryBlue.withOpacity(0.65),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<BannerModel>>(
              future: _bannersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!.withOpacity(0.5),
                    highlightColor: Colors.grey[100]!.withOpacity(0.5),
                    child: Container(height: 180, width: double.infinity, color: Colors.white),
                  );
                }
                final banners = snapshot.data ?? [];
                if (banners.isEmpty) return const SizedBox.shrink();
                
                return CarouselSlider.builder(
                  itemCount: banners.length,
                  options: CarouselOptions(
                    height: 180,
                    autoPlay: true,
                    viewportFraction: 1.0,
                  ),
                  itemBuilder: (context, index, realIndex) {
                    final banner = banners[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(banner.imageUrl, fit: BoxFit.cover, width: double.infinity),
                      ),
                    );
                  },
                ).animate().fade(duration: 500.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOut);
              }
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: AutoplayVideoPlayer(
                videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-charity-collector-collecting-coins-in-a-box-41584-large.mp4',
              ),
            ),
            const SizedBox(height: 20),
            _buildSuccessStoryCard(),
            const SizedBox(height: 20),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Our Causes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDarkBlue)),
            ).animate().fade(delay: 200.ms).slideX(begin: -0.1),
            
            FutureBuilder<List<CampaignModel>>(
              future: _campaignsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!.withOpacity(0.5),
                    highlightColor: Colors.grey[100]!.withOpacity(0.5),
                    child: Container(
                      height: 380,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load campaigns'));
                }

                final campaigns = snapshot.data ?? [];
                
                if (campaigns.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No active campaigns right now. Check back later!'),
                  ));
                }

                return Column(
                  children: [
                    CarouselSlider.builder(
                      itemCount: campaigns.length,
                      options: CarouselOptions(
                        height: 440,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 5),
                        enlargeCenterPage: true,
                        viewportFraction: 0.85,
                      ),
                      itemBuilder: (context, index, realIndex) {
                        final campaign = campaigns[index];
                        final progress = campaign.amountRequired > 0 
                            ? campaign.amountCollected / campaign.amountRequired 
                            : 0.0;
                        final percent = (progress * 100).toInt();

                        // Cycle through campaign colors
                        final colors = [AppColors.campaignPurple, AppColors.primaryBlue, AppColors.campaignOrange];
                        final cardColor = colors[index % colors.length];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => CampaignDetailsScreen(
                              campaignId: campaign.id,
                              title: campaign.title,
                              collected: campaign.amountCollected,
                              required: campaign.amountRequired,
                              imageUrl: campaign.images.isNotEmpty ? campaign.images.first : '',
                            )));
                          },
                          child: GlassyContainer(
                            color: Colors.white,
                            opacity: 0.12,
                            borderRadius: BorderRadius.circular(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  child: Container(
                                    height: 180,
                                    width: double.infinity,
                                    color: Colors.white.withOpacity(0.05),
                                    child: campaign.images.isNotEmpty ? Image.network(
                                      campaign.images.first,
                                      fit: BoxFit.cover,
                                    ) : const Center(child: Icon(Icons.image, size: 48, color: Colors.grey)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        campaign.title,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDarkBlue),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'We provide support to those in need to create long-term positive change and build a brighter future.',
                                        style: TextStyle(fontSize: 12, color: Colors.black54),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 16),
                                      LinearProgressIndicator(
                                        value: progress.clamp(0.0, 1.0),
                                        backgroundColor: cardColor.withOpacity(0.2),
                                        color: cardColor,
                                        minHeight: 6,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Raised: ₹${campaign.amountCollected} / ₹${campaign.amountRequired}', 
                                            style: const TextStyle(fontSize: 11, color: Colors.black54),
                                          ),
                                          Text('Progress: $percent%', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (_) => CampaignDetailsScreen(
                                              campaignId: campaign.id,
                                              title: campaign.title,
                                              collected: campaign.amountCollected,
                                              required: campaign.amountRequired,
                                              imageUrl: campaign.images.isNotEmpty ? campaign.images.first : '',
                                            )));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: cardColor,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                            elevation: 0,
                                          ),
                                          child: const Text('DONATE NOW ↗', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                                        )
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                    ),

                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text('Explore', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDarkBlue)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.2,
                        children: [
                          _buildExploreCard(context, 'Food Donate', Icons.volunteer_activism, const FoodDonateScreen(), 0),
                          _buildExploreCard(context, 'Account Details', Icons.account_balance, const AccountDetailsScreen(), 1),
                          _buildExploreCard(context, 'Legal Documents', Icons.article, const LegalDocumentsScreen(), 2),
                          _buildExploreCard(context, 'Events', Icons.event, const EventsScreen(), 3),
                          _buildExploreCard(context, 'Gallery', Icons.photo_library, const GalleryScreen(), 4),
                          _buildExploreCard(context, 'News', Icons.newspaper, const NewsFeedScreen(), 5),
                          _buildExploreCard(context, 'About', Icons.info_outline, const AboutScreen(), 6),
                        ],
                      ),
                    ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
                    const SizedBox(height: 100), // extra padding for extendBody BottomNavigationBar
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreCard(BuildContext context, String title, IconData icon, Widget screen, int index) {
    bool isPressed = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
          },
          child: AnimatedScale(
            scale: isPressed ? 0.94 : 1.0,
            duration: 100.ms,
            child: GlassyContainer(
              borderRadius: BorderRadius.circular(16),
              opacity: 0.08,
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 36, color: AppColors.primaryBlue),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDarkBlue),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
      delay: (index * 80).ms,
    ).slideY(
      begin: 0,
      end: -0.02,
      duration: (2000 + (index * 150)).ms,
      curve: Curves.easeInOut,
    );
  }

  Widget _buildSuccessStoryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GlassyContainer(
        padding: const EdgeInsets.all(24),
        color: Colors.white,
        opacity: 0.08,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(20),
                color: AppColors.primaryBlue.withOpacity(0.05),
              ),
              child: const Text('SUCCESS STORY', style: TextStyle(color: AppColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Changing lives through compassion & action',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textDarkBlue,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We work tirelessly to uplift underprivileged communities through food support, education, healthcare, and basic necessities.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).slideY(
      begin: 0,
      end: -0.015,
      duration: 3.seconds,
      curve: Curves.easeInOut,
    );
  }
}
