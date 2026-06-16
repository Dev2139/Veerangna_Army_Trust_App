import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('About Us', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.armyGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image
            Image.network(
              'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Building futures, one step at a time – nurturing hope & childhood dreams',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'At Ranchhodbhai Dhirjalal Parkara, We Work With Compassion And Commitment To Create A Safe, Healthy, And Supportive Environment For Children And Underprivileged Families. Through Food, Healthcare, Education, And Community Care, We Help Build Brighter Futures - One Life At A Time.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Key Areas Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.75,
                    children: [
                      _buildKeyAreaCard(
                        icon: Icons.restaurant,
                        title: 'Healthy Food',
                        desc: 'Providing Nutritious Meals To Children And Families So No One Sleeps Hungry And Every Child Grows Strong And Healthy.',
                      ),
                      _buildKeyAreaCard(
                        icon: Icons.medical_services,
                        title: 'Medical Help',
                        desc: 'Offering Essential Medical Support, Health Check-Ups, And Emergency Assistance To Those Who Cannot Afford Basic Healthcare.',
                      ),
                      _buildKeyAreaCard(
                        icon: Icons.group,
                        title: 'Social Responsibilities',
                        desc: 'Standing By Communities During Difficult Times Through Relief Drives, Awareness Programs, And Social Welfare Initiatives.',
                      ),
                      _buildKeyAreaCard(
                        icon: Icons.volunteer_activism,
                        title: 'Community Support',
                        desc: 'Empowering Local Communities By Promoting Care, Unity, Education, And Long-Term Development.',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  const Text(
                    'Explore our faqs for quick & helpful guidance',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ranchhodbhai Dhirjalal Parkara Believes In Transparency, Compassion, And Collective Responsibility. Here Are Answers To Some Common Questions About Our Charitable Work And How You Can Be A Part Of It.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // FAQs
                  _buildFaqItem(
                    'What is charity, and why is it important?',
                    'Charity Not Only Helps To Reduce Suffering But Also Fosters A Sense Of Unity And Shared Responsibility In Society.',
                  ),
                  _buildFaqItem(
                    'How Can I Get Involved In Charity Work ?',
                    'You can get involved by volunteering your time, making donations, or simply spreading awareness about our cause in your community.',
                  ),
                  _buildFaqItem(
                    'What is our dedication towards charitable donations?',
                    'We ensure 100% transparency in all our operations. Every penny donated goes directly towards the welfare of the underprivileged.',
                  ),
                  _buildFaqItem(
                    'My Donations Are Going To a Charity ?',
                    'Yes, all your contributions are directed exclusively to our registered charitable trust and utilized for authorized social welfare projects.',
                  ),
                  _buildFaqItem(
                    'Is my donation actually being put to use?',
                    'Absolutely. We provide regular updates, reports, and galleries to showcase the real-world impact of your generous donations.',
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Bottom Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1532629345422-7515f3d16bb0?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyAreaCard({required IconData icon, required String title, required String desc}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.armyGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.armyGreen, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        iconColor: AppColors.armyGreen,
        collapsedIconColor: AppColors.textSecondary,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
