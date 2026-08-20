import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/health_profile.dart';
import '../database/database_helper.dart';

class AuthProvider with ChangeNotifier {
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserHeight = 'user_height';
  static const String _keyUserIsAdmin = 'user_is_admin';

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  List<User> _allUsers = [];

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  List<User> get allRegisteredUsers => _allUsers;

  final DatabaseHelper _db = DatabaseHelper.instance;

  AuthProvider() {
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_keyUserId);
    final email = prefs.getString(_keyUserEmail);
    final name = prefs.getString(_keyUserName);
    final height = prefs.getDouble(_keyUserHeight);
    final isAdmin = prefs.getBool(_keyUserIsAdmin) ?? false;

    if (userId != null && email != null && name != null && height != null) {
      _currentUser = User(
        id: userId,
        name: name,
        email: email,
        password: '',
        height: height,
        isAdmin: isAdmin,
      );
    }
    _allUsers = await _db.getAllUsers();
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
          isLocked: false,
          createdAt: '18/08/2026',
        );
        final id = await _db.insertUser(adminUser);
        user = User(
          id: id,
          name: adminUser.name,
          email: adminUser.email,
          password: adminUser.password,
          height: adminUser.height,
          isAdmin: true,
          isLocked: false,
          createdAt: '18/08/2026',
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

      // Kiểm tra trạng thái khóa tài khoản
      if (user.isLocked) {
        _errorMessage = 'Tài khoản của bạn đã bị khóa bởi Quản trị viên! Vui lòng liên hệ quản trị.';
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

  Future<bool> loginAsGuest() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Tìm hoặc tạo tài khoản khách mặc định
      var guest = await _db.getUserByEmail('guest@healthtracker.app');
      if (guest == null) {
        final newGuest = User(
          name: 'Khách Trải Nghiệm',
          email: 'guest@healthtracker.app',
          password: 'GuestPassword123',
          height: 170.0,
          isAdmin: false,
          isLocked: false,
          createdAt: '20/08/2026',
        );
        final id = await _db.insertUser(newGuest);
        guest = newGuest.copyWith(id: id);
        final now = DateTime.now().toIso8601String();
        await _db.upsertHealthProfile(HealthProfile(
          userId: id,
          fullName: 'Khách Trải Nghiệm',
          height: 170.0,
          currentWeight: 65.0,
          targetWeight: 60.0,
          createdAt: now,
          updatedAt: now,
        ));
      }

      _currentUser = guest;
      await _saveUserSession(guest);
      _allUsers = await _db.getAllUsers();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi đăng nhập khách: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
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
      final existingUser = await _db.getUserByEmail(email.trim().toLowerCase());
      if (existingUser != null) {
        _errorMessage = 'Email này đã được đăng ký!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final nowStr = '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}';
      final newUser = User(
        name: name.trim(),
        email: email.trim(),
        password: password,
        height: height,
        isAdmin: false,
        isLocked: false,
        createdAt: nowStr,
      );

      final id = await _db.insertUser(newUser);
      _currentUser = User(
        id: id,
        name: newUser.name,
        email: newUser.email,
        password: newUser.password,
        height: newUser.height,
        isAdmin: false,
        isLocked: false,
        createdAt: nowStr,
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

  // Quản trị viên: Tải lại danh sách người dùng
  Future<void> refreshAllUsers() async {
    _allUsers = await _db.getAllUsers();
    notifyListeners();
  }

  // Quản trị viên: Khóa / Mở khóa tài khoản
  Future<void> toggleUserLock(int userId, bool isLocked) async {
    await _db.toggleUserLock(userId, isLocked);
    await refreshAllUsers();
  }

  // Quản trị viên: Xóa tài khoản
  Future<void> deleteUser(int userId) async {
    await _db.deleteUser(userId);
    await refreshAllUsers();
  }

  // Quản trị viên: Đặt lại trạng thái người dùng (Mở khóa)
  Future<void> resetUserStatus(int userId) async {
    await _db.resetUserStatus(userId);
    await refreshAllUsers();
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
