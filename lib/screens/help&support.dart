import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Help & Support", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff00b7df),
        leading: BackButton(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text(
              "How can we help you?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildHelpItem(
              icon: Icons.question_answer,
              title: "FAQs",
              subtitle: "Browse frequently asked questions.",
              onTap: () {
                Navigator.pushNamed(context, '/FAQs');
              },
            ),
            _buildHelpItem(
              icon: Icons.mail_outline,
              title: "Contact Support",
              subtitle: "Reach us by email for technical issues.",
              onTap: () {
                Navigator.pushNamed(context, '/contact');
              },
            ),
            _buildHelpItem(
              icon: Icons.feedback_outlined,
              title: "Send Feedback",
              subtitle: "Let us know how we can improve.",
              onTap: () {
                Navigator.pushNamed(context, '/Send_Feedback');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Color(0xff00b7df), size: 28),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}