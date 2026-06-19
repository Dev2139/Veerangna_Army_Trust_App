import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/api_service.dart';
import '../../data/models/user_model.dart';
import '../auth/login_screen.dart';
import 'certificate_screen.dart';
import 'billing_info_screen.dart';
import 'id_card_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/glassy_container.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  late Future<UserModel?> _profileFuture;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _apiService.getUserProfile();
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primaryBlue),
                title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primaryBlue),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final updated = await _apiService.uploadProfilePhoto(pickedFile.path);
      if (updated != null) {
        setState(() {
          _profileFuture = _apiService.getUserProfile();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo uploaded successfully!'), backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload photo.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint('Upload Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                Container(height: 140, color: Colors.white),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
                          const SizedBox(width: 16),
                          Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Container(height: 50, color: Colors.white),
                      const SizedBox(height: 10),
                      Container(height: 50, color: Colors.white),
                    ]
                  )
                )
              ]
            )
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Failed to load profile. Please log in again.'));
        }

        final user = snapshot.data!;

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GlassyContainer(
                  padding: const EdgeInsets.all(20),
                  color: AppColors.primaryBlue,
                  opacity: 0.12,
                  borderRadius: BorderRadius.circular(24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.white.withOpacity(0.15),
                              backgroundImage: (user.profilePhotoUrl != null && user.profilePhotoUrl!.isNotEmpty && !_isUploadingPhoto)
                                  ? NetworkImage(user.profilePhotoUrl!)
                                  : null,
                              child: _isUploadingPhoto
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: AppColors.primaryBlue, strokeWidth: 2),
                                    )
                                  : (user.profilePhotoUrl == null || user.profilePhotoUrl!.isEmpty)
                                      ? const Icon(Icons.person, size: 36, color: AppColors.primaryBlue)
                                      : null,
                            ),
                            if (!_isUploadingPhoto)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: const TextStyle(color: AppColors.textDarkBlue, fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(user.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
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
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Impact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDarkBlue)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Total Donated', '₹ ${user.totalDonated.toInt()}', Icons.volunteer_activism, AppColors.saffron, 0)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard('Campaigns', '${user.savedCampaigns.length}', Icons.campaign, AppColors.primaryBlue, 1)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text('Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDarkBlue)),
                    const SizedBox(height: 12),
                    _buildMenuItem(Icons.history, 'Donation History', () {
                      _showDonationHistory(context, user.donationHistory);
                    }, 0),
                    _buildMenuItem(Icons.card_membership, 'My Certificates', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CertificateScreen(user: user)));
                    }, 1),
                    _buildMenuItem(Icons.badge, 'My ID Card', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => IDCardScreen(user: user)));
                    }, 2),
                    _buildMenuItem(Icons.receipt_long, 'Billing Information', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BillingInfoScreen(user: user)),
                      ).then((_) {
                        setState(() {
                          _profileFuture = _apiService.getUserProfile();
                        });
                      });
                    }, 3),
                    _buildMenuItem(Icons.bookmark, 'Saved Campaigns', null, 4),
                    _buildMenuItem(Icons.settings, 'Settings', null, 5),
                    const SizedBox(height: 32),
                    Center(
                      child: TextButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 100), // padding for bottom navigation bar
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void _showDonationHistory(BuildContext context, List<dynamic> history) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GlassyContainer(
          color: Colors.white,
          opacity: 0.15,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Donation History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDarkBlue)),
                const SizedBox(height: 16),
                Expanded(
                  child: history.isEmpty
                      ? const Center(child: Text('No donations yet. Thank you for your support!', style: TextStyle(color: AppColors.textSecondary)))
                      : ListView.builder(
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final donation = history[index];
                            final amount = donation['amount'] ?? 0;
                            final date = donation['createdAt'] != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(donation['createdAt'])) : 'Unknown';
                            final campaignName = donation['campaign'] != null ? donation['campaign']['title'] : 'Campaign';
                            return GlassyContainer(
                              margin: const EdgeInsets.only(bottom: 10),
                              color: Colors.white,
                              opacity: 0.05,
                              borderRadius: BorderRadius.circular(12),
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: ListTile(
                                leading: const CircleAvatar(backgroundColor: AppColors.primaryBlue, child: Icon(Icons.volunteer_activism, color: Colors.white, size: 20)),
                                title: Text('₹$amount - $campaignName', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDarkBlue)),
                                subtitle: Text(date, style: const TextStyle(color: AppColors.textSecondary)),
                                trailing: const Icon(Icons.check_circle, color: Colors.green),
                              ),
                            );
                          },
                        ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, int index) {
    return GlassyContainer(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      opacity: 0.08,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDarkBlue)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
      delay: (index * 150).ms,
    ).slideY(
      begin: 0,
      end: -0.02,
      duration: (2000 + (index * 200)).ms,
      curve: Curves.easeInOut,
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback? onTap, int index) {
    return GlassyContainer(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      opacity: 0.05,
      borderRadius: BorderRadius.circular(12),
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDarkBlue)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap ?? () {},
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
      delay: (index * 100).ms,
    ).slideY(
      begin: 0,
      end: -0.015,
      duration: (2100 + (index * 150)).ms,
      curve: Curves.easeInOut,
    );
  }
}
