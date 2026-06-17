import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/api_service.dart';
import '../../data/models/gallery_model.dart';
import '../../core/widgets/glassy_container.dart';
import '../../core/widgets/glassy_background.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class FoodDonateScreen extends StatefulWidget {
  const FoodDonateScreen({Key? key}) : super(key: key);

  @override
  State<FoodDonateScreen> createState() => _FoodDonateScreenState();
}

class _FoodDonateScreenState extends State<FoodDonateScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<GalleryModel>> _foodGalleryFuture;
  
  final List<Map<String, dynamic>> donationOptions = [
    {'children': 21, 'amount': 525},
    {'children': 41, 'amount': 1025},
    {'children': 51, 'amount': 1275},
    {'children': 71, 'amount': 1775},
    {'children': 101, 'amount': 2525},
    {'children': 151, 'amount': 3775},
    {'children': 251, 'amount': 6275},
    {'children': 501, 'amount': 12525},
  ];

  int? selectedAmountIndex;
  TextEditingController customAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _foodGalleryFuture = _apiService.getFoodGallery();
  }

  @override
  void dispose() {
    customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Donate Food', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Top Banner as a Floating Glassy Container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GlassyContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  color: AppColors.primaryBlue,
                  opacity: 0.15,
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.volunteer_activism, color: AppColors.saffron),
                          SizedBox(width: 8),
                          Text(
                            'ARMY TRUST DONATION',
                            style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Their Future Needs Your Help',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE74C3C),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Your Donation Can Fill A Child's Empty Plate",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFB300),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              ).slideY(
                begin: 0,
                end: -0.012,
                duration: 3.seconds,
                curve: Curves.easeInOut,
              ),
              
              const SizedBox(height: 20),
              
              // Donation Form Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GlassyContainer(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  opacity: 0.08,
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      const Text(
                        'Donate Food To Children Suffering From Hunger',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '(After Donating You Can Easily Download Your 80G Donation Receipt)',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      
                      // Selected Amount Display
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3), width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                              ),
                              child: const Text('₹', style: TextStyle(color: AppColors.primaryBlue, fontSize: 22, fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              child: Text(
                                selectedAmountIndex != null 
                                    ? '${donationOptions[selectedAmountIndex!]['amount']}'
                                    : customAmountController.text.isNotEmpty ? customAmountController.text : '0',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('AMOUNT', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Donation Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: donationOptions.length,
                        itemBuilder: (context, index) {
                          final option = donationOptions[index];
                          final isSelected = selectedAmountIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedAmountIndex = index;
                                customAmountController.clear();
                              });
                            },
                            child: GlassyContainer(
                              color: isSelected ? AppColors.primaryBlue : Colors.white,
                              opacity: isSelected ? 0.35 : 0.05,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryBlue : Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${option['children']} बच्चों को भोजन',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.textDarkBlue,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${option['amount']}',
                                    style: TextStyle(
                                      color: isSelected ? Color(0xFFFFB300) : AppColors.primaryBlue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      const Text('Custom Amount', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: customAmountController,
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {
                            selectedAmountIndex = null;
                          });
                        },
                        style: const TextStyle(color: AppColors.textDarkBlue, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: 'Enter custom amount',
                          hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.primaryBlue),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment gateway integration pending.')));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                          child: const Text('DONATE NOW', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Videos Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GlassyContainer(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                  color: Colors.white,
                  opacity: 0.08,
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      const Text(
                        'Help Us Donate Food To As Many Needy As Possible!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE74C3C),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildYouTubeThumbnail('hcY_TqUIXKM', 0),
                            const SizedBox(width: 15),
                            _buildYouTubeThumbnail('Ohgo25tz-m4', 1),
                            const SizedBox(width: 15),
                            _buildYouTubeThumbnail('s3KSzrj6pio', 2),
                            const SizedBox(width: 15),
                            _buildYouTubeThumbnail('3uC36eGuPwQ', 3),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text('View More Videos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Real Photos Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GlassyContainer(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                  color: Colors.white,
                  opacity: 0.08,
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(text: 'Real Photos ', style: TextStyle(color: Color(0xFFE74C3C))),
                            TextSpan(text: 'Real Change!', style: TextStyle(color: AppColors.primaryBlue)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      FutureBuilder<List<GalleryModel>>(
                        future: _foodGalleryFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                          }
                          
                          final images = snapshot.data ?? [];
                          
                          if (images.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('No food donation photos yet.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                            );
                          }
                          
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return GlassyContainer(
                                color: Colors.white,
                                opacity: 0.05,
                                borderRadius: BorderRadius.circular(16),
                                padding: const EdgeInsets.all(4),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    images[index].imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ).animate(
                                onPlay: (controller) => controller.repeat(reverse: true),
                                delay: (index * 100).ms,
                              ).slideY(
                                begin: 0,
                                end: -0.015,
                                duration: (2100 + (index * 180)).ms,
                                curve: Curves.easeInOut,
                              );
                            },
                          );
                        }
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYouTubeThumbnail(String videoId, int index) {
    final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    final videoUrl = Uri.parse('https://youtu.be/$videoId');
    
    return GestureDetector(
      onTap: () async {
        if (await canLaunchUrl(videoUrl)) {
          await launchUrl(videoUrl, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch video')));
          }
        }
      },
      child: GlassyContainer(
        width: 250,
        height: 150,
        color: Colors.white,
        opacity: 0.05,
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(thumbnailUrl, fit: BoxFit.cover),
              Container(color: Colors.black.withOpacity(0.25)),
              Center(
                child: GlassyContainer(
                  width: 50,
                  height: 50,
                  color: Colors.red,
                  opacity: 0.65,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white38),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        ),
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
}
