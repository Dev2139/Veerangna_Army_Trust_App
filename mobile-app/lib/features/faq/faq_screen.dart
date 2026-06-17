import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glassy_container.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class FaqScreen extends StatelessWidget {
  const FaqScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> faqs = const [
    {
      'question': 'How can I make a donation?',
      'answer': 'You can make a donation by navigating to the Home screen, selecting a Featured Campaign, and tapping the "Contribute" button. You can choose from multiple payment methods.'
    },
    {
      'question': 'Where does my money go?',
      'answer': '100% of your donations go directly towards supporting the families of our brave soldiers, providing education, healthcare, and financial assistance.'
    },
    {
      'question': 'Are my donations tax-deductible?',
      'answer': 'Yes, all donations made through the Army Trust app are eligible for tax exemption under section 80G of the Income Tax Act.'
    },
    {
      'question': 'How can I get a receipt for my donation?',
      'answer': 'You will receive an automated email receipt immediately after a successful transaction. You can also view and download past receipts from the Profile section.'
    },
    {
      'question': 'Can I donate anonymously?',
      'answer': 'Yes, during the checkout process, you have the option to check "Donate Anonymously". Your personal details will not be displayed publicly on the campaign page.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('FAQ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue.withOpacity(0.65),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return GlassyContainer(
            margin: const EdgeInsets.only(bottom: 12.0),
            color: Colors.white,
            opacity: 0.08,
            borderRadius: BorderRadius.circular(16),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: AppColors.primaryBlue,
                collapsedIconColor: Colors.grey,
                title: Text(
                  faqs[index]['question']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      faqs[index]['answer']!,
                      style: const TextStyle(color: Colors.black87, height: 1.5),
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
    );
  }
}
