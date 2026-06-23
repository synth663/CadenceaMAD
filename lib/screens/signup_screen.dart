import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_text_styles.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _userTagController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  Map<String, String> _errors = {};

  bool _validateForm() {
    final errors = <String, String>{};
    if (_fullNameController.text.trim().isEmpty) errors['fullName'] = 'Full name is required';
    if (_userTagController.text.trim().isEmpty) {
      errors['userTag'] = 'User tag is required';
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(_userTagController.text)) {
      errors['userTag'] = 'User tag can only contain letters, numbers, and underscores';
    }
    if (_emailController.text.trim().isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_emailController.text)) {
      errors['email'] = 'Please enter a valid email address';
    }
    if (_passwordController.text.isEmpty) {
      errors['password'] = 'Password is required';
    } else if (_passwordController.text.length < 8) {
      errors['password'] = 'Password must be at least 8 characters';
    }
    if (_confirmPasswordController.text.isEmpty) {
      errors['confirmPassword'] = 'Please confirm your password';
    } else if (_passwordController.text != _confirmPasswordController.text) {
      errors['confirmPassword'] = 'Passwords do not match';
    }
    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    await auth.signup(
      fullName: _fullNameController.text,
      email: _emailController.text,
      username: _userTagController.text,
      password: _passwordController.text,
    );
    setState(() => _isLoading = false);
    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _userTagController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: Colors.white),
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
                      color: const Color(0xFFE88219),
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
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12.0),
            ),
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
              // Back button
              GestureDetector(
                onTap: () => context.go('/welcome'),
                child: Row(
                  children: [
                    const Icon(LucideIcons.arrowLeft, size: 20.0, color: Color(0xFFE88219)),
                    const SizedBox(width: 8.0),
                    Text(
                      'Back',
                      style: AppTextStyles.bodySM.copyWith(color: const Color(0xFFE88219), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              // Logo & Title
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
                    'Create Account',
                    style: AppTextStyles.h1.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              // Form fields
              _buildTextField(
                label: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: LucideIcons.user,
                controller: _fullNameController,
                errorText: _errors['fullName'],
                fieldKey: 'fullName',
              ),
              const SizedBox(height: 20.0),
              _buildTextField(
                label: 'User Tag',
                hintText: 'Choose a unique user tag',
                prefixIcon: LucideIcons.atSign,
                controller: _userTagController,
                errorText: _errors['userTag'],
                fieldKey: 'userTag',
              ),
              const SizedBox(height: 20.0),
              _buildTextField(
                label: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: LucideIcons.mail,
                controller: _emailController,
                errorText: _errors['email'],
                keyboardType: TextInputType.emailAddress,
                fieldKey: 'email',
              ),
              const SizedBox(height: 20.0),
              _buildTextField(
                label: 'Password',
                hintText: 'Create a password',
                prefixIcon: LucideIcons.lock,
                controller: _passwordController,
                errorText: _errors['password'],
                obscureText: !_showPassword,
                suffixIcon: _showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                onSuffixTap: () => setState(() => _showPassword = !_showPassword),
                fieldKey: 'password',
              ),
              const SizedBox(height: 20.0),
              _buildTextField(
                label: 'Confirm Password',
                hintText: 'Re-enter your password',
                prefixIcon: LucideIcons.lock,
                controller: _confirmPasswordController,
                errorText: _errors['confirmPassword'],
                obscureText: !_showConfirmPassword,
                suffixIcon: _showConfirmPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                onSuffixTap: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                fieldKey: 'confirmPassword',
              ),
              const SizedBox(height: 48.0),
              // Create Account Button
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
                          'Create Account',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 24.0),
              // Sign In link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodySM.copyWith(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Sign In',
                        style: AppTextStyles.bodySM.copyWith(
                          color: const Color(0xFFE88219),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
