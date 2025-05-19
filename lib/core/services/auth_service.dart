import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    initAuth();
  }

  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // In the future, this will check Firebase Auth state
      // For now, we'll check shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId != null) {
        // Mock user data - in real app, fetch from Firebase
        await _fetchUserData(userId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _fetchUserData(String userId) async {
    // Mock fetch - in real app, fetch from Firebase
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data
    _currentUser = User(
      id: userId,
      name: userId.contains('teacher') ? 'Teacher Name' : 'Student Name',
      email: userId.contains('teacher') ? 'teacher@example.com' : 'student@example.com',
      role: userId.contains('teacher') ? UserRole.teacher :
      userId.contains('admin') ? UserRole.admin : UserRole.student,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLogin: DateTime.now(),
      grade: userId.contains('student') ? '10th' : null,
    );
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, you would authenticate with Firebase here
      // For now, let's just mock the login

      // Mock validation
      if (email.isEmpty || password.isEmpty) {
        _error = 'Please enter email and password';
        return false;
      }

      // Mock successful login
      final prefs = await SharedPreferences.getInstance();

      String userId;
      if (email.contains('teacher')) {
        userId = 'teacher_${const Uuid().v4()}';
      } else if (email.contains('admin')) {
        userId = 'admin_${const Uuid().v4()}';
      } else {
        userId = 'student_${const Uuid().v4()}';
      }

      await prefs.setString('user_id', userId);
      await _fetchUserData(userId);

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? grade,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, you would register with Firebase here
      // For now, let's just mock the registration

      // Mock validation
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        _error = 'Please fill in all required fields';
        return false;
      }

      // Mock successful registration
      final prefs = await SharedPreferences.getInstance();

      String userId;
      if (role == UserRole.teacher) {
        userId = 'teacher_${const Uuid().v4()}';
      } else if (role == UserRole.admin) {
        userId = 'admin_${const Uuid().v4()}';
      } else {
        userId = 'student_${const Uuid().v4()}';
      }

      await prefs.setString('user_id', userId);

      _currentUser = User(
        id: userId,
        name: name,
        email: email,
        role: role,
        grade: grade,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, sign out from Firebase here
      // For now, just clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}