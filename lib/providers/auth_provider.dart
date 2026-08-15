import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../database/database_helper.dart';
import '../utils/security_helper.dart';
import '../utils/validators.dart';

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

  /// Attempts to log in a user with email and password.
  /// 
  /// Returns true if login successful, false otherwise.
  /// Sets [errorMessage] if login fails.
  /// Validates email format and password before attempting login.
  /// Passwords are verified using SHA-256 hashing.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate email format
      if (!Validators.isValidEmail(email.trim())) {
        _errorMessage = 'Email không hợp lệ. Vui lòng kiểm tra lại!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate password not empty
      if (password.isEmpty) {
        _errorMessage = 'Mật khẩu không được để trống!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check Admin demo credentials (special case - for demo purposes)
      if (email.trim().toLowerCase() == 'admin@healthtracker.app' && password == 'Admin@123') {
        _currentUser = User(
          id: 1,
          name: 'Quản Trị Viên (Admin)',
          email: 'admin@healthtracker.app',
          password: 'admin',
          height: 175.0,
          isAdmin: true,
        );
        await _saveUserSession(_currentUser!);
        _allUsers = await _db.getAllUsers();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      final user = await _db.getUserByEmail(email.trim());
      if (user == null) {
        _errorMessage = 'Email chưa được đăng ký trong hệ thống!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verify password using hash comparison
      if (!SecurityHelper.verifyPassword(password, user.password)) {
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

  /// Logs in as a guest user without authentication.
  /// 
  /// Guest users can explore the app without creating an account.
  /// Guest data is not persisted and will be lost on app restart.
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

  /// Registers a new user account.
  /// 
  /// Validates all inputs before creating the account:
  /// - Name must not be empty
  /// - Email must be valid format
  /// - Password must meet strength requirements (min 6 chars, 1 uppercase, 1 number)
  /// - Height must be between 100-250 cm
  /// 
  /// Password is hashed using SHA-256 before storing.
  /// Returns true if registration successful, false otherwise.
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
      // Validate name
      if (name.trim().isEmpty) {
        _errorMessage = 'Họ tên không được để trống!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate email
      final emailError = Validators.getEmailError(email);
      if (emailError != null) {
        _errorMessage = emailError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate password strength
      final passwordError = Validators.getPasswordError(password);
      if (passwordError != null) {
        _errorMessage = passwordError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate height
      final heightError = Validators.getHeightError(height);
      if (heightError != null) {
        _errorMessage = heightError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final existingUser = await _db.getUserByEmail(email.trim());
      if (existingUser != null) {
        _errorMessage = 'Email này đã được đăng ký!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Hash password before storing
      final hashedPassword = SecurityHelper.hashPassword(password);

      final newUser = User(
        name: name.trim(),
        email: email.trim(),
        password: hashedPassword,
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

  /// Logs out the current user.
  /// 
  /// Clears all user session data from SharedPreferences
  /// and resets the current user to null.
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
