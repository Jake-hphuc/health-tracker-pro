import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'onboarding_flow_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _heightController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      height: double.parse(_heightController.text.trim()),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Đăng ký thất bại!'),
          backgroundColor: AppColors.appleRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final isWide = AppConstants.isWide(context);

    Widget formContent = Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.appleGreen, AppColors.appleBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.appleGreen.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tạo Tài Khoản Mới',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Bắt đầu hành trình chăm sóc sức khỏe toàn diện',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.label2,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 28),

          // Name Field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập họ và tên';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ Email',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập Email';
              }
              if (!value.contains('@')) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.label2,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              if (value.length < 6) {
                return 'Mật khẩu phải từ 6 ký tự trở lên';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Height Field
          TextFormField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Chiều cao (cm)',
              prefixIcon: Icon(Icons.height_rounded, size: 20),
              suffixText: 'cm',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập chiều cao';
              }
              final h = double.tryParse(value);
              if (h == null || h <= 50 || h > 250) {
                return 'Chiều cao không hợp lệ (50 - 250 cm)';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Register Button
          ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appleBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'ĐĂNG KÝ TÀI KHOẢN',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
          ),
          const SizedBox(height: 20),

          // Back to Login Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Đã có tài khoản? ',
                style: TextStyle(color: AppColors.label2, fontSize: 14),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Đăng Nhập Ngay',
                  style: TextStyle(
                    color: AppColors.appleBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: isWide
            ? Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Container(
                    width: 460,
                    padding: const EdgeInsets.all(36),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.card1 : Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: formContent,
                  ),
                ),
              )
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  child: formContent,
                ),
              ),
      ),
    );
  }
}
