import 'package:deep_fake/screens/login_page.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _controller = PageController();
  int currentIndex = 0;

  List<Map<String, String>> pages = [
    {
      'image': 'assets/screen1.png',
      'title': 'Image Authenticity Checker App',
      'subtitle': 'Quickly Detect Fake Or Edited Images',
    },
    {
      'image': 'assets/screen2.png', 
      'title': 'Secure & Accurate',
      'subtitle': 'Powered by advanced deepfake detection',
    },
    {
      'image': 'assets/screen3.png',
      'title': 'Get Started!',
      'subtitle': 'Upload an image and begin analysis',
    },
  ];

  void nextPage() {
    if (currentIndex < pages.length - 1) {
      _controller.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final page = pages[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                page['image']!,
                height: 400,
              ),
              SizedBox(height: 20),
              Text(
                page['title']!,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                page['subtitle']!,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (i) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: currentIndex == i ? 12 : 8,
                    height: currentIndex == i ? 12 : 8,
                    decoration: BoxDecoration(
                      color:
                          currentIndex == i ? Color(0xff00b6de) : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff00b6de),
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(16),
                ),
                child: Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }
}
