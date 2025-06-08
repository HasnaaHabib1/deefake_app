import 'package:flutter/material.dart';
import 'package:deep_fake/services/auth_service.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  final String token;

  const VerificationPage({
    Key? key,
    required this.email,
    required this.token,
  }) : super(key: key);

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  late String email;
  late String token;

  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    email = widget.email;
    token = widget.token;

    authService.setToken(token);
    print(' Token set in AuthService: $token');
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> verifyOtp() async {
    if (otpController.text.trim().isEmpty) {
      _showDialog('Please enter the OTP code.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await authService.verifyOtpAndRegister(
        email: email,
        otpCode: otpController.text.trim(),
      );

      if (response['status'] == true) {
        _showDialog('Verification successful! You can now log in.');
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        _showDialog(response['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      _showDialog('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<void> resendOtp() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   try {
  //     final response = await authService.resendOtp(email: email);
  //     if (response['status'] == true) {
  //       _showDialog('OTP resent successfully.');
  //     } else {
  //       _showDialog(response['message'] ?? 'Failed to resend OTP.');
  //     }
  //   } catch (e) {
  //     _showDialog('Error: $e');
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        backgroundColor: const Color(0xff00bcd4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'We have sent an OTP code to $email',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'OTP Code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff00bcd4),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verify OTP', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                print('Resend Otp');
              },
              // onPressed: isLoading ? null : sendOtp,
              child: const Text(
                'Resend OTP',
                style: TextStyle(
                  color: Color(0xff00bcd4),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
