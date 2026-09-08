import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _currentUser = '';
  final String _defaultPassword = '123456';

  bool get isLoggedIn => _isLoggedIn;
  String get currentUser => _currentUser;

  // Register new user
  bool register(String email, String password, String confirmPassword) {
    // Validate email
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Please enter a valid email address');
    }

    // Validate password
    if (password.isEmpty) {
      throw Exception('Please enter a password');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters long');
    }

    // Validate confirm password
    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }

    // Save user data (simulated)
    _currentUser = email;
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  // Login user
  bool login(String email, String password) {
    // Validate email
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Please enter a valid email address');
    }

    // Validate password
    if (password.isEmpty) {
      throw Exception('Please enter your password');
    }

    // Check password (fixed password: 123456)
    if (password != _defaultPassword) {
      throw Exception('Invalid password. Default password is: 123456');
    }

    // Login successful
    _currentUser = email;
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  // Logout user
  void logout() {
    _isLoggedIn = false;
    _currentUser = '';
    notifyListeners();
  }

  // Reset password (just for demo)
  bool resetPassword(String email) {
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Please enter a valid email address');
    }
    return true;
  }
}