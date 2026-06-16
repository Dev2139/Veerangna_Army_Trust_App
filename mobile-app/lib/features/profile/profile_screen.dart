import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/api_service.dart';
import '../../data/models/user_model.dart';
import '../auth/login_screen.dart';
import 'certificate_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  late Future<UserModel?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _apiService.getUserProfile();
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
              Container(
                color: AppColors.armyGreen,
                padding: const EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.white,
                      child: Icon(Icons.person, size: 40, color: AppColors.armyGreen),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(user.email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Impact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Total Donated', '₹ ${user.totalDonated.toInt()}', Icons.volunteer_activism, AppColors.saffron)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard('Campaigns', '\${user.savedCampaigns.length}', Icons.campaign, AppColors.armyGreen)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text('Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildMenuItem(Icons.history, 'Donation History', () {
                      _showDonationHistory(context, user.donationHistory);
                    }),
                    _buildMenuItem(Icons.card_membership, 'My Certificates', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CertificateScreen(user: user)));
                    }),
                    _buildMenuItem(Icons.bookmark, 'Saved Campaigns', null),
                    _buildMenuItem(Icons.settings, 'Settings', null),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Logout', style: TextStyle(color: Colors.red)),
                      ),
                    )
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Donation History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: history.isEmpty
                    ? const Center(child: Text('No donations yet. Thank you for your support!'))
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final donation = history[index];
                          final amount = donation['amount'] ?? 0;
                          final date = donation['createdAt'] != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(donation['createdAt'])) : 'Unknown';
                          final campaignName = donation['campaign'] != null ? donation['campaign']['title'] : 'Campaign';
                          return ListTile(
                            leading: const CircleAvatar(backgroundColor: AppColors.armyGreen, child: Icon(Icons.volunteer_activism, color: Colors.white, size: 20)),
                            title: Text('₹$amount - $campaignName', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(date),
                            trailing: const Icon(Icons.check_circle, color: Colors.green),
                          );
                        },
                      ),
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.armyGreen),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      contentPadding: EdgeInsets.zero,
      onTap: onTap ?? () {},
    );
  }
}
