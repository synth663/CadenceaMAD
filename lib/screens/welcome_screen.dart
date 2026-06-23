import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_text_styles.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // Logo
              Container(
                width: 96.0,
                height: 96.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFE88219),
                  borderRadius: BorderRadius.circular(28.0),
                ),
                child: const Icon(
                  Icons.music_note,
                  size: 48.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24.0),
              // Title
              Text(
                'Cadencea',
                style: AppTextStyles.h1.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 36,
                ),
              ),
              const Spacer(flex: 2),
              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 56.0,
                child: ElevatedButton(
                  onPressed: () => context.go('/signup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE88219),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 56.0,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E2621),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Sign Up With Google Button
              SizedBox(
                width: double.infinity,
                height: 56.0,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF2E2621),
                        title: const Text('OAuth', style: TextStyle(color: Colors.white)),
                        content: const Text('Google OAuth popup redirect placeholder.', style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close', style: TextStyle(color: Color(0xFFE88219))),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF9F8F7),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                        height: 24.0,
                        width: 24.0,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 32, color: Colors.black),
                      ),
                      const SizedBox(width: 12.0),
                      const Text(
                        'Sign Up With Google',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Footer
              Text(
                'By continuing you agree to the\nTerms and Conditions and Privacy Policy',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white70,
                  fontSize: 12.0,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
