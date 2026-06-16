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
import '../../data/models/banner_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

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
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            _markAllAsSeen();
          }
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.armyGreen,
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
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network('https://res.cloudinary.com/dsddldquo/image/upload/v1781593109/tsrwudiwazhmwm78oa4g.jpg', height: 32, width: 32, fit: BoxFit.cover),
            ),
            const SizedBox(width: 8),
            const Text('Army Trust', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: AppColors.armyGreen,
        elevation: 0,
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
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
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
            
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Featured Campaigns', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ).animate().fade(delay: 200.ms).slideX(begin: -0.1),
            
            FutureBuilder<List<CampaignModel>>(
              future: _campaignsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
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
                        height: 380,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 4),
                        enlargeCenterPage: true,
                        viewportFraction: 0.85,
                      ),
                      itemBuilder: (context, index, realIndex) {
                        final campaign = campaigns[index];
                        final progress = campaign.amountRequired > 0 
                            ? campaign.amountCollected / campaign.amountRequired 
                            : 0.0;

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
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                        image: campaign.images.isNotEmpty ? DecorationImage(
                                          image: NetworkImage(campaign.images.first),
                                          fit: BoxFit.cover,
                                        ) : null,
                                      ),
                                      child: campaign.images.isEmpty ? const Center(child: Icon(Icons.image, size: 48, color: Colors.grey)) : null,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    campaign.title,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: progress.clamp(0.0, 1.0),
                                    backgroundColor: Colors.grey[200],
                                    color: AppColors.saffron,
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '₹ ${campaign.amountCollected} raised', 
                                          style: const TextStyle(color: AppColors.armyGreen, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => CampaignDetailsScreen(
                                            campaignId: campaign.id,
                                            title: campaign.title,
                                            collected: campaign.amountCollected,
                                            required: campaign.amountRequired,
                                            imageUrl: campaign.images.isNotEmpty ? campaign.images.first : '',
                                          )));
                                        },
                                        child: const Text('Contribute', style: TextStyle(color: AppColors.saffron)),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ).animate(delay: Duration(milliseconds: 300 + (index * 100))).fade().scale(begin: const Offset(0.95, 0.95));
                      },
                    ),

                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text('Explore', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                          _buildExploreCard(context, 'Food Donate', Icons.volunteer_activism, const FoodDonateScreen()),
                          _buildExploreCard(context, 'Events', Icons.event, const EventsScreen()),
                          _buildExploreCard(context, 'Gallery', Icons.photo_library, const GalleryScreen()),
                          _buildExploreCard(context, 'News', Icons.newspaper, const NewsFeedScreen()),
                          _buildExploreCard(context, 'About', Icons.info_outline, const AboutScreen()),
                        ],
                      ),
                    ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
                    const SizedBox(height: 40),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreCard(BuildContext context, String title, IconData icon, Widget screen) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppColors.armyGreen),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
