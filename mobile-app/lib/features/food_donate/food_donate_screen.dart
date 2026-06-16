import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/api_service.dart';
import '../../data/models/gallery_model.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Donate Food', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.armyGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Banner
            Container(
              color: const Color(0xFF27AE60), // Match the bright green from design
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.volunteer_activism, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'ARMY TRUST DONATION',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Their Future Needs Your Help',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE74C3C), // Red color
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Your Donation Can Fill An Child's Empty Plate",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF1C40F), // Yellow color
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            
            // Donation Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Donate Food To Children Suffering From Hunger',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.armyGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '(After Donating You Can Easily Download Your 80G Donation Receipt)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  
                  // Selected Amount Display
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.armyGreen, width: 2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          color: AppColors.armyGreen,
                          child: const Text('₹', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: Text(
                            selectedAmountIndex != null 
                                ? '${donationOptions[selectedAmountIndex!]['amount']}'
                                : customAmountController.text.isNotEmpty ? customAmountController.text : '0',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.armyGreen),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('AMOUNT TO DONATE', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        )
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.armyGreen : Colors.white,
                            border: Border.all(color: AppColors.armyGreen),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${option['children']} बच्चों को भोजन दान करें',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.armyGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${option['amount']}',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.armyGreen,
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
                  
                  const SizedBox(height: 20),
                  const Text('Custom Amount', style: TextStyle(color: AppColors.armyGreen, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: customAmountController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      setState(() {
                        selectedAmountIndex = null;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter custom amount',
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.armyGreen, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.armyGreen, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.armyGreen, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement payment
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment gateway integration pending.')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.armyGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('DONATE NOW', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
            
            // Videos Section
            Container(
              color: const Color(0xFFD5E8D4), // Light green background
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              child: Column(
                children: [
                  const Text(
                    'Help Us Donate Food To As Many Needy As Possible!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE74C3C), // Red
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildYouTubeThumbnail('hcY_TqUIXKM'),
                        const SizedBox(width: 15),
                        _buildYouTubeThumbnail('Ohgo25tz-m4'),
                        const SizedBox(width: 15),
                        _buildYouTubeThumbnail('s3KSzrj6pio'),
                        const SizedBox(width: 15),
                        _buildYouTubeThumbnail('3uC36eGuPwQ'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('View More Videos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.armyGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  )
                ],
              ),
            ),
            
            // Real Photos Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              child: Column(
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(text: 'Real Photos ', style: TextStyle(color: Color(0xFFE74C3C))),
                        TextSpan(text: 'Real Change!', style: TextStyle(color: AppColors.armyGreen)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  FutureBuilder<List<GalleryModel>>(
                    future: _foodGalleryFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.armyGreen));
                      }
                      
                      final images = snapshot.data ?? [];
                      
                      if (images.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('No food donation photos yet.', textAlign: TextAlign.center),
                        );
                      }
                      
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              images[index].imageUrl,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      );
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYouTubeThumbnail(String videoId) {
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
      child: Container(
        width: 250,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(thumbnailUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withOpacity(0.3),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}
