import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/health_profile.dart';
import '../database/database_helper.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  static const String _keyUserId = 'logged_in_user_id';
  static const String _keyUserEmail = 'logged_in_user_email';
  static const String _keyUserName = 'logged_in_user_name';
  static const String _keyUserHeight = 'logged_in_user_height';
  static const String _keyUserIsAdmin = 'logged_in_user_is_admin';

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  List<User> _allUsers = [];

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  List<User> get allRegisteredUsers => _allUsers;

  AuthProvider() {
    _loadSavedUser();
  }

  Future<void> _loadSavedUser() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_keyUserId);
    final userEmail = prefs.getString(_keyUserEmail);
    final userName = prefs.getString(_keyUserName);
    final userHeight = prefs.getDouble(_keyUserHeight);
    final isAdmin = prefs.getBool(_keyUserIsAdmin) ?? false;

    if (userId != null && userEmail != null && userName != null) {
      _currentUser = User(
        id: userId,
        email: userEmail,
        name: userName,
        password: '',
        height: userHeight ?? 170.0,
        isAdmin: isAdmin,
      );
    }

    _allUsers = await _db.getAllUsers();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanEmail = email.trim().toLowerCase();
      var user = await _db.getUserByEmail(cleanEmail);

      // Nếu là tài khoản admin nhưng chưa có trong SQLite (bản DB cũ), tự động khởi tạo
      if (user == null && cleanEmail == 'admin@healthtracker.app' && password == 'Admin@123') {
        final adminUser = User(
          name: 'Quản Trị Viên',
          email: 'admin@healthtracker.app',
          password: 'Admin@123',
          height: 175.0,
          isAdmin: true,
        );
        final id = await _db.insertUser(adminUser);
        user = User(
          id: id,
          name: adminUser.name,
          email: adminUser.email,
          password: adminUser.password,
          height: adminUser.height,
          isAdmin: true,
        );
      }

      if (user == null) {
        _errorMessage = 'Email chưa được đăng ký trong hệ thống!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (user.password != password) {
        _errorMessage = 'Mật khẩu không chính xác!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      await _saveUserSession(user);
      _allUsers = await _db.getAllUsers();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Đăng nhập thất bại: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void loginAsGuest() {
    _currentUser = User(
      id: 999,
      name: 'Khách Trải Nghiệm 👤',
      email: 'guest@healthtracker.app',
      password: '',
      height: 170.0,
      isAdmin: false,
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
      final existingUser = await _db.getUserByEmail(email.trim());
      if (existingUser != null) {
        _errorMessage = 'Email này đã được đăng ký!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final newUser = User(
        name: name.trim(),
        email: email.trim(),
        password: password,
        height: height,
        isAdmin: false,
      );

      final id = await _db.insertUser(newUser);
      _currentUser = User(
        id: id,
        name: newUser.name,
        email: newUser.email,
        password: newUser.password,
        height: newUser.height,
        isAdmin: false,
      );

      // Tạo hồ sơ sức khỏe mặc định ban đầu cho user mới
      final now = DateTime.now().toIso8601String();
      final initProfile = HealthProfile(
        userId: id,
        fullName: newUser.name,
        height: newUser.height,
        currentWeight: 65.0,
        targetWeight: 60.0,
        createdAt: now,
        updatedAt: now,
      );
      await _db.upsertHealthProfile(initProfile);

      await _saveUserSession(_currentUser!);
      _allUsers = await _db.getAllUsers();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi khi đăng ký tài khoản: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user.id != null) await prefs.setInt(_keyUserId, user.id!);
    await prefs.setString(_keyUserEmail, user.email);
    await prefs.setString(_keyUserName, user.name);
    await prefs.setDouble(_keyUserHeight, user.height);
    await prefs.setBool(_keyUserIsAdmin, user.isAdmin);
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserHeight);
    await prefs.remove(_keyUserIsAdmin);
    notifyListeners();
  }
}
