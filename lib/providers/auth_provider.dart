import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  static const String _keyUserId    = 'logged_user_id';
  static const String _keyUserEmail = 'logged_user_email';
  // static const String _keyUserName  = 'logged_user_name';
  static const String _keyIsAdmin   = 'logged_is_admin';
  static const String _keyAllUsers  = 'all_registered_users';

  User? _currentUser;
  bool  _isGuest   = false;
  bool  _isLoading = false;
  String? _errorMessage;

  User?   get currentUser  => _currentUser;
  bool    get isLoggedIn   => _currentUser != null;
  bool    get isGuest      => _isGuest;
  bool    get isAdmin      => _currentUser?.isAdmin ?? false;
  bool    get isLoading    => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() { _init(); }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Admin password hash for "Admin@123"
  static final String _adminHash = sha256.convert(utf8.encode('Admin@123')).toString();
  static const String _adminEmail = 'admin@healthtracker.app';

  Future<void> _init() async {
    await _seedAdminToPrefs();
    await _loadUserFromPrefs();
  }

  /// Seed admin account into SharedPreferences if not exists
  Future<void> _seedAdminToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAllUsers) ?? '[]';
    final List decoded = jsonDecode(raw);
    final users = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    final hasAdmin = users.any((u) => u['email'] == _adminEmail);
    if (!hasAdmin) {
      users.add({
        'id': 1,
        'name': 'Administrator',
        'email': _adminEmail,
        'password': _adminHash,
        'height': 170.0,
        'created_at': DateTime.now().toIso8601String(),
        'is_admin': 1,
      });
      await prefs.setString(_keyAllUsers, jsonEncode(users));
    }
    // Also seed into DatabaseHelper web store
    DatabaseHelper.instance.seedAdmin(_adminEmail, _adminHash);
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_keyUserEmail);
    if (email != null) {
      final savedUser = await _getUserByEmailFromPrefs(email);
      if (savedUser != null) {
        _isGuest     = false;
        _currentUser = savedUser;
        notifyListeners();
        return;
      }
      _currentUser = await DatabaseHelper.instance.getUserByEmail(email);
      if (_currentUser != null) notifyListeners();
    }
  }

  Future<User?> _getUserByEmailFromPrefs(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAllUsers) ?? '[]';
    final List decoded = jsonDecode(raw);
    try {
      final map = decoded.firstWhere(
        (e) => (e['email'] as String).toLowerCase() == email.toLowerCase(),
      ) as Map;
      return User.fromMap(Map<String, dynamic>.from(map));
    } catch (_) {
      return null;
    }
  }

  Future<List<User>> getAllRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAllUsers) ?? '[]';
    final List decoded = jsonDecode(raw);
    return decoded
        .map((e) => User.fromMap(Map<String, dynamic>.from(e)))
        .where((u) => !u.isAdmin)
        .toList();
  }

  void loginAsGuest() {
    _isGuest     = true;
    _currentUser = User(
      id: 999999,
      name: 'Khach Trai Nghiem',
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
      // Check existing in prefs
      final existing = await _getUserByEmailFromPrefs(email);
      if (existing != null) {
        _errorMessage = 'Email nay da duoc dang ky!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final hashedPassword = _hashPassword(password);
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyAllUsers) ?? '[]';
      final List decoded = jsonDecode(raw);
      final newId = decoded.length + 1;
      final newUserMap = {
        'id': newId,
        'name': name,
        'email': email,
        'password': hashedPassword,
        'height': height,
        'created_at': DateTime.now().toIso8601String(),
        'is_admin': 0,
      };
      decoded.add(newUserMap);
      await prefs.setString(_keyAllUsers, jsonEncode(decoded));

      final newUser = User.fromMap(Map<String, dynamic>.from(newUserMap));
      // Also add to DatabaseHelper web store
      await DatabaseHelper.instance.createUser(newUser);

      _isGuest     = false;
      _currentUser = newUser;
      await prefs.setString(_keyUserEmail, email);
      await prefs.setInt(_keyUserId, newId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Da xay ra loi khi dang ky: $e';
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
      final hashedPassword = _hashPassword(password);

      // First check SharedPreferences store (works on web + mobile)
      User? user = await _getUserByEmailFromPrefs(email);
      if (user == null) {
        // Fallback to database
        user = await DatabaseHelper.instance.getUserByEmail(email);
      }

      if (user == null) {
        _errorMessage = 'Email chua duoc dang ky!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (user.password != hashedPassword) {
        _errorMessage = 'Mat khau khong chinh xac!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isGuest     = false;
      _currentUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserEmail, email);
      await prefs.setInt(_keyUserId, user.id ?? 0);
      await prefs.setBool(_keyIsAdmin, user.isAdmin);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Da xay ra loi khi dang nhap: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    _isGuest     = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyIsAdmin);
    notifyListeners();
  }
}