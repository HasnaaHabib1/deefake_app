import 'package:flutter/material.dart';
import 'package:deep_fake/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  void _startSplash() async {

    await Future.delayed(Duration(seconds: 3));

    bool isLoggedIn = await _authService.loadTokenAndUser();
    bool isFirstTime = await _authService.isFirstTimeUser();

    if (isFirstTime) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff00b6dd),
      body: Center(
        child: Text(
          'DEFAKE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}
