import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:deep_fake/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isChecked = false;
  bool isPasswordVisible = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/register.png', height: 160),
              const SizedBox(height: 24),
              const Text(
                'Get Started',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'by creating a free account.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildTextField('Full Name', Icons.person,
                  controller: nameController),
              _buildTextField('Email', Icons.email,
                  controller: emailController),
              _buildTextField('Password', Icons.lock,
                  obscure: !isPasswordVisible,
                  isPassword: true,
                  controller: passwordController),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'By checking the box you agree to our ',
                        children: [
                          TextSpan(
                            text: 'Terms and Conditions.',
                            style: TextStyle(color: Colors.teal),
                          ),
                        ],
                      ),
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isChecked
                    ? () async {
                        try {
                          final response = await authService.register(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            password: passwordController.text,
                            phone: '01111111111', // مؤقتًا
                          );

                          if (response['status'] == true) {
                            String token = response['token'];
                            authService.setToken(token);


                            Navigator.pushNamed(
                              context,
                              '/verify',
                              arguments: {
                                'email': emailController.text.trim(),
                                'token': token,
                              },
                            );
                          } else {
                            _showDialog(response['message'] ?? 'Unknown error');
                          }
                        } catch (e) {
                          _showDialog(e.toString());
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff00bcd4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Next', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'Already a member? ',
                      children: [
                        TextSpan(
                          text: 'Log In',
                          style: const TextStyle(color: Colors.teal),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pop(context);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon,
      {bool obscure = false,
      bool isPassword = false,
      required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
