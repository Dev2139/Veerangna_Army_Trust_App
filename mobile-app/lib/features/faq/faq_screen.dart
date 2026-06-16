import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('FAQ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.armyGreen,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              title: Text(
                faqs[index]['question']!,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.armyGreen),
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
          );
        },
      ),
    );
  }
}
