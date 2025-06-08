import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Privacy Policy", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff00b7df),
        leading: BackButton(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Privacy Policy",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "At DEFAKE, we are committed to protecting your personal data and ensuring transparency about how it is used within our application.",
                style: TextStyle(fontSize: 16, height: 1.6),
              ),
              SizedBox(height: 24),
              Text("1. Data Collection", style: _sectionTitleStyle()),
              SizedBox(height: 8),
              Text(
                "We collect only the necessary information to provide our services. This includes:\n"
                "- Email address for login and account recovery.\n"
                "- Uploaded images and videos for deepfake analysis.\n"
                "- Usage data to improve the app experience.",
                style: _bodyTextStyle(),
              ),
              SizedBox(height: 24),
              Text("2. Data Usage", style: _sectionTitleStyle()),
              SizedBox(height: 8),
              Text(
                "Your data is used strictly for the purpose of analyzing media content and enhancing our detection algorithms. We do not share your data with third parties.",
                style: _bodyTextStyle(),
              ),
              SizedBox(height: 24),
              Text("3. Storage & Security", style: _sectionTitleStyle()),
              SizedBox(height: 8),
              Text(
                "All data is stored securely using industry-standard encryption. Uploaded media is deleted after processing unless required for future analysis by the user.",
                style: _bodyTextStyle(),
              ),
              SizedBox(height: 24),
              Text("4. User Rights", style: _sectionTitleStyle()),
              SizedBox(height: 8),
              Text(
                "You may request to update or delete your personal data at any time. Please contact our support team through the 'Contact Us' section for assistance.",
                style: _bodyTextStyle(),
              ),
              SizedBox(height: 24),
              Text("5. Policy Updates", style: _sectionTitleStyle()),
              SizedBox(height: 8),
              Text(
                "This privacy policy may be updated from time to time. All changes will be communicated within the app or via email.",
                style: _bodyTextStyle(),
              ),
              SizedBox(height: 40),
              Text(
                "If you have any questions or concerns regarding our privacy practices, please don't hesitate to reach out.",
                style: _bodyTextStyle(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _sectionTitleStyle() {
    return TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  }

  TextStyle _bodyTextStyle() {
    return TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[800]);
  }
}
