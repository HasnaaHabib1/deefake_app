import 'dart:io';
import 'package:flutter/material.dart';

// Screens
import 'screens/splash _screen.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home_page.dart';
import 'screens/result_page.dart';
import 'screens/OnboardingScreen.dart';
import 'screens/profile_overview_page.dart';
import 'screens/edit_profile.dart';
import 'screens/history_page.dart';
import 'screens/forget_pass.dart';
import 'screens/contact_us.dart';
import 'screens/privacy_policy.dart';
import 'screens/help&support.dart';
import 'screens/verification_page.dart';
import 'screens/FAQs.dart';
import 'screens/reset_password.dart';
import 'screens/verify_reset_otp.dart';
import 'screens/Send_Feedback.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deepfake Detector',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => SplashScreen());

          case '/onboarding':
            return MaterialPageRoute(builder: (_) => OnboardingScreen());

          case '/login':
            return MaterialPageRoute(builder: (_) => LoginPage());

          case '/register':
            return MaterialPageRoute(builder: (_) => RegisterPage());

          case '/verify':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args == null ||
                !args.containsKey('email') ||
                !args.containsKey('token')) {
              return _errorRoute(settings.name);
            }
            return MaterialPageRoute(
              builder: (_) => VerificationPage(
                email: args['email'],
                token: args['token'],
              ),
            );

          case '/home':
            return MaterialPageRoute(builder: (_) => HomePage());

          case '/result':
            final args = settings.arguments;
            if (args is! File) return _errorRoute(settings.name);
            return MaterialPageRoute(
                builder: (_) => ResultPage(imageFile: args));

          case '/profile':
            return MaterialPageRoute(builder: (_) => ProfileOverviewScreen());

          case '/edit_profile':
            return MaterialPageRoute(builder: (_) => EditProfileScreen());

          case '/history':
            return MaterialPageRoute(builder: (_) => HistoryScreen());

          case '/forget':
            return MaterialPageRoute(builder: (_) => ForgotPasswordPage());

          case '/contact':
            return MaterialPageRoute(builder: (_) => ContactUsPage());

          case '/privacy':
            return MaterialPageRoute(builder: (_) => PrivacyPolicyPage());

          case '/help':
            return MaterialPageRoute(builder: (_) => HelpSupportPage());

          case '/FAQs':
            return MaterialPageRoute(builder: (_) => FAQsPage());

          case '/Send_Feedback':
            return MaterialPageRoute(builder: (_) => SendFeedbackPage());

          case '/reset_password':
            return MaterialPageRoute(builder: (_) => ResetPasswordPage());

          case '/verify_reset_otp':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args == null ||
                !args.containsKey('email') ||
                !args.containsKey('token')) {
              return _errorRoute(settings.name);
            }
            return MaterialPageRoute(
              builder: (_) => VerifyResetPasswordPage(
                email: args['email'],
                token: args['token'],
              ),
            );

          default:
            return _errorRoute(settings.name);
        }
      },
    );
  }

  Route _errorRoute(String? name) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('No route defined for $name')),
      ),
    );
  }
}
