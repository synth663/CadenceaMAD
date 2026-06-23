import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;
  Map<String, String> _errors = {};

  bool _validateForm() {
    final errors = <String, String>{};
    if (_emailController.text.trim().isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_emailController.text)) {
      errors['email'] = 'Please enter a valid email address';
    }
    if (_passwordController.text.isEmpty) {
      errors['password'] = 'Password is required';
    }
    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    await auth.login(email: _emailController.text, password: _passwordController.text);
    setState(() => _isLoading = false);
    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
    String? errorText,
    bool obscureText = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    TextInputType? keyboardType,
    String fieldKey = '',
    Widget? rightLabelWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.label.copyWith(color: Colors.white)),
            if (rightLabelWidget != null) rightLabelWidget,
          ],
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 56.0,
          decoration: BoxDecoration(
            color: const Color(0xFF2E2621),
            borderRadius: BorderRadius.circular(16.0),
            border: errorText != null ? Border.all(color: Colors.redAccent) : null,
          ),
          child: Row(
            children: [
              const SizedBox(width: 16.0),
              Icon(prefixIcon, color: Colors.white54, size: 20.0),
              const SizedBox(width: 12.0),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 16.0),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) {
                    if (_errors.containsKey(fieldKey)) {
                      setState(() => _errors.remove(fieldKey));
                    }
                  },
                ),
              ),
              if (suffixIcon != null)
                GestureDetector(
                  onTap: onSuffixTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Icon(
                      suffixIcon,
                      color: obscureText ? Colors.white54 : const Color(0xFFE88219),
                      size: 20.0,
                    ),
                  ),
                )
              else
                const SizedBox(width: 16.0),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6.0),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(errorText, style: const TextStyle(color: Colors.redAccent, fontSize: 12.0)),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0B),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12.0),
              GestureDetector(
                onTap: () => context.go('/welcome'),
                child: Row(
                  children: [
                    const Icon(LucideIcons.arrowLeft, size: 20.0, color: Colors.white54),
                    const SizedBox(width: 8.0),
                    Text(
                      'Back',
                      style: AppTextStyles.bodySM.copyWith(color: Colors.white54, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              Row(
                children: [
                  Container(
                    width: 72.0,
                    height: 72.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE88219),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Icon(Icons.music_note, size: 36.0, color: Colors.white),
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    'Welcome Back',
                    style: AppTextStyles.h1.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48.0),
              _buildTextField(
                label: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: LucideIcons.mail,
                controller: _emailController,
                errorText: _errors['email'],
                keyboardType: TextInputType.emailAddress,
                fieldKey: 'email',
              ),
              const SizedBox(height: 24.0),
              _buildTextField(
                label: 'Password',
                hintText: 'Enter your password',
                prefixIcon: LucideIcons.lock,
                controller: _passwordController,
                errorText: _errors['password'],
                obscureText: !_showPassword,
                suffixIcon: !_showPassword ? LucideIcons.eye : LucideIcons.eyeOff,
                onSuffixTap: () => setState(() => _showPassword = !_showPassword),
                fieldKey: 'password',
                rightLabelWidget: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Forgot Password?',
                    style: AppTextStyles.label.copyWith(color: const Color(0xFFE88219), fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 48.0),
              SizedBox(
                width: double.infinity,
                height: 56.0,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE88219),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE88219).withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 16.0),
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
                        content: const Text('Google OAuth login redirect placeholder.', style: TextStyle(color: Colors.white70)),
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
                        'Continue With Google',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48.0),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.bodySM.copyWith(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/signup'),
                      child: Text(
                        'Create Account',
                        style: AppTextStyles.bodySM.copyWith(
                          color: const Color(0xFFE88219),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              Center(
                child: Text(
                  'By signing in, you agree to our Terms & Privacy Policy',
                  style: AppTextStyles.caption.copyWith(color: Colors.white38),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48.0),
            ],
          ),
        ),
      ),
    );
  }
}
