import 'package:flutter/material.dart';

class FAQsPage extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      'question': 'How to reset my password?',
      'answer': 'Go to the Edite Profile page and tap on "Reset Password". Follow the instructions sent to your email.'
    },
    {
      'question': 'How to contact support?',
      'answer': 'You can contact support by tapping "Contact Support" in the Help & Support page or send us an email.'
    },
  
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FAQs"),
        backgroundColor: Color(0xff00b7df),
        leading: BackButton(color: Colors.white),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return ExpansionTile(
            title: Text(faq['question']!),
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(faq['answer']!),
              )
            ],
          );
        },
      ),
    );
  }
}