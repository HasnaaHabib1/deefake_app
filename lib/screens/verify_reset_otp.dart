import 'package:flutter/material.dart';
import 'package:deep_fake/services/auth_service.dart';
import 'reset_password.dart';

class VerifyResetPasswordPage extends StatelessWidget {
  final String email;

  const VerifyResetPasswordPage({Key? key, required this.email, required token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController otpController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Reset Password'),
        backgroundColor: const Color(0xff00bcd4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'We have sent an OTP code to $email to reset your password',
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
              onPressed: () async {
                final otp = otpController.text.trim();
                if (otp.isEmpty) return;

                try {
                  var token = '';
                  bool success = await AuthService().verifyResetOtp(
                    email: email,
                    otpCode: otp, token: token,
                  );

                  if (success) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResetPasswordPage(email: email),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid OTP, please try again')),
                    );
                  }
                } catch (e) {
                  print('Error verifying OTP: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error verifying OTP: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff00bcd4),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Verify OTP',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                try {
                  await AuthService().sendOtp(email);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OTP resent successfully')),
                  );
                } catch (e) {
                  print('Failed to resend OTP: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to resend OTP: $e')),
                  );
                }
              },
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
