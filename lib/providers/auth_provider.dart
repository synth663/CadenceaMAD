import 'package:flutter/material.dart';
import '../models/user_profile.dart';

/// Auth state management — matches SignUp.tsx / Login.tsx flow.
/// Uses mock data for now; can be connected to a real backend later.
class AuthProvider extends ChangeNotifier {
  UserProfile? _currentUser;
  bool _isLoggedIn = false;

  UserProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  /// Sign up with form fields — simulates account creation.
  Future<bool> signup({
    required String fullName,
    required String email,
    required String username,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Create user from form data
    final initials = fullName
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    _currentUser = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName,
      initials: initials,
      email: email,
      avgScore: 0,
      performanceCount: 0,
      achievementCount: 0,
    );
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  /// Login with email/password — simulates authentication.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Use mock user for demo
    _currentUser = UserProfile.mockUser;
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  /// Logout — clears the current user session.
  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
