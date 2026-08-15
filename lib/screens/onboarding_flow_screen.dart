import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/health_provider.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding data
  String _gender = 'Nam';
  int _age = 25;
  double _weight = 65.0;
  String _primaryGoal = 'Tăng cường sức khỏe';
  int _waterGoal = 2000;
  int _activityGoal = 30;
  double _sleepGoal = 8.0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final health = Provider.of<HealthProvider>(context, listen: false);

    if (auth.currentUser != null) {
      health.updateGoals(
        water: _waterGoal,
        sleep: _sleepGoal,
        activity: _activityGoal,
      );
      health.addWeight(_weight, auth.currentUser!.height);
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip & Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(4, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.appleGreen
                              : (isDark ? AppColors.card2 : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  TextButton(
                    onPressed: _finish,
                    child: const Text('Bỏ qua', style: TextStyle(color: AppColors.label2)),
                  ),
                ],
              ),
            ),

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildWelcomePage(isDark),
                  _buildBodyInfoPage(isDark),
                  _buildGoalsSelectionPage(isDark),
                  _buildDailyTargetsPage(isDark),
                ],
              ),
            ),

            // Bottom Navigation Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appleGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _currentPage == 3 ? 'BẮT ĐẦU NGAY' : 'TIẾP TỤC',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.appleRed, AppColors.appleGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.appleGreen.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 72),
          ),
          const SizedBox(height: 32),
          const Text(
            'Chào Mừng Bạn Đến Với\nHealth Tracker Pro',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Ứng dụng cá nhân hóa giúp bạn xây dựng lối sống lành mạnh, tràn đầy năng lượng mỗi ngày.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.label2, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyInfoPage(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Thông Tin Cơ Thể',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 6),
        const Text(
          'Giúp chúng tôi tính toán lượng calo và mục tiêu chuẩn xác nhất cho bạn.',
          style: TextStyle(fontSize: 13, color: AppColors.label2),
        ),
        const SizedBox(height: 24),

        // Gender Selector
        const Text('Giới tính', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: ['Nam', 'Nữ', 'Khác'].map((g) {
            final isSel = _gender == g;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _gender = g),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.appleBlue : (isDark ? AppColors.card1 : Colors.white),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSel ? AppColors.appleBlue : (isDark ? AppColors.separator : Colors.grey.shade300),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    g,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Age & Weight Sliders
        Text('Tuổi: $_age tuổi', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Slider(
          value: _age.toDouble(),
          min: 10,
          max: 90,
          activeColor: AppColors.appleGreen,
          onChanged: (v) => setState(() => _age = v.toInt()),
        ),
        const SizedBox(height: 10),

        Text('Cân nặng hiện tại: ${_weight.toStringAsFixed(1)} kg',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Slider(
          value: _weight,
          min: 30,
          max: 150,
          divisions: 240,
          activeColor: AppColors.appleOrange,
          onChanged: (v) => setState(() => _weight = v),
        ),
      ],
    );
  }

  Widget _buildGoalsSelectionPage(bool isDark) {
    final goals = [
      'Giảm cân & Đốt mỡ thừa',
      'Tăng cân & Phát triển cơ bắp',
      'Tăng cường sức bền & Dẻo dai',
      'Xây dựng thói quen sống lành mạnh',
    ];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Mục Tiêu Của Bạn',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 6),
        const Text(
          'Chọn mục tiêu chính bạn muốn hướng đến.',
          style: TextStyle(fontSize: 13, color: AppColors.label2),
        ),
        const SizedBox(height: 20),

        ...goals.map((g) {
          final isSel = _primaryGoal == g;
          return GestureDetector(
            onTap: () => setState(() => _primaryGoal = g),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isSel ? AppColors.appleGreen.withValues(alpha: 0.15) : (isDark ? AppColors.card1 : Colors.white),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSel ? AppColors.appleGreen : (isDark ? AppColors.separator : Colors.grey.shade300),
                  width: isSel ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSel ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: isSel ? AppColors.appleGreen : AppColors.label3,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      g,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDailyTargetsPage(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Thiết Lập Mục Tiêu Hàng Ngày',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 6),
        const Text(
          'Chúng tôi gợi ý các chỉ số chuẩn khoa học cho bạn.',
          style: TextStyle(fontSize: 13, color: AppColors.label2),
        ),
        const SizedBox(height: 24),

        // Water Goal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('💧 Uống nước:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('$_waterGoal ml', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.appleBlue)),
          ],
        ),
        Slider(
          value: _waterGoal.toDouble(),
          min: 1000,
          max: 4000,
          divisions: 30,
          activeColor: AppColors.appleBlue,
          onChanged: (v) => setState(() => _waterGoal = v.toInt()),
        ),
        const SizedBox(height: 14),

        // Activity Goal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🔥 Vận động:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('$_activityGoal phút', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.appleRed)),
          ],
        ),
        Slider(
          value: _activityGoal.toDouble(),
          min: 15,
          max: 120,
          divisions: 21,
          activeColor: AppColors.appleRed,
          onChanged: (v) => setState(() => _activityGoal = v.toInt()),
        ),
        const SizedBox(height: 14),

        // Sleep Goal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('😴 Giấc ngủ:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('${_sleepGoal.toStringAsFixed(1)} giờ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.applePurple)),
          ],
        ),
        Slider(
          value: _sleepGoal,
          min: 5.0,
          max: 10.0,
          divisions: 10,
          activeColor: AppColors.applePurple,
          onChanged: (v) => setState(() => _sleepGoal = v),
        ),
      ],
    );
  }
}
