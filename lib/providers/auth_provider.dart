import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  static const String _keyUserId = 'logged_user_id';
  static const String _keyUserEmail = 'logged_user_email';

  User? _currentUser;
  bool _isGuest = false;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isGuest => _isGuest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _loadUserFromPrefs();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_keyUserEmail);
    if (email != null) {
      _isGuest = false;
      _currentUser = await DatabaseHelper.instance.getUserByEmail(email);
      notifyListeners();
    }
  }

  void loginAsGuest() {
    _isGuest = true;
    _currentUser = User(
      id: 999999,
      name: 'Khách Trải Nghiệm 👤',
      email: 'khach@healthtracker.app',
      password: '',
      height: 170.0,
      createdAt: DateTime.now().toIso8601String(),
    );
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required double height,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final existingUser = await DatabaseHelper.instance.getUserByEmail(email);
      if (existingUser != null) {
        _errorMessage = 'Email này đã được đăng ký!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final hashedPassword = _hashPassword(password);
      final newUser = User(
        name: name,
        email: email,
        password: hashedPassword,
        height: height,
        createdAt: DateTime.now().toIso8601String(),
      );

      final createdUser = await DatabaseHelper.instance.createUser(newUser);
      if (createdUser != null) {
        _isGuest = false;
        _currentUser = createdUser;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyUserEmail, email);
        await prefs.setInt(_keyUserId, createdUser.id ?? 0);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi khi đăng ký: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await DatabaseHelper.instance.getUserByEmail(email);
      if (user == null) {
        _errorMessage = 'Email chưa được đăng ký!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final hashedPassword = _hashPassword(password);
      if (user.password != hashedPassword) {
        _errorMessage = 'Mật khẩu không chính xác!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isGuest = false;
      _currentUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserEmail, email);
      await prefs.setInt(_keyUserId, user.id ?? 0);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi khi đăng nhập: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    _isGuest = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserId);
    notifyListeners();
  }
}
