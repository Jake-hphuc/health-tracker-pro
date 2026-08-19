import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/health_provider.dart';
import '../providers/schedule_provider.dart';
import '../models/health_profile.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'goals_screen.dart';
import 'onboarding_flow_screen.dart';
import 'admin_dashboard_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _waterReminder = true;
  bool _sleepReminder = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final healthProvider = Provider.of<HealthProvider>(context);
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = AppConstants.isWide(context);

    final user = authProvider.currentUser;
    final isAdmin = user?.isAdmin ?? false;
    final profile = healthProvider.healthProfile;
    final cardBg = isDark ? AppColors.card1 : Colors.white;

    final body = ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 28 : 20,
        vertical: 16,
      ),
      children: [
        // User Profile Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: isAdmin
                    ? const Color(0xFF6C47FF).withValues(alpha: 0.15)
                    : AppColors.appleGreen.withValues(alpha: 0.15),
                child: Icon(
                  isAdmin ? Icons.shield_rounded : Icons.person_rounded,
                  size: 34,
                  color: isAdmin ? const Color(0xFF6C47FF) : AppColors.appleGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile?.fullName.isNotEmpty == true
                                ? profile!.fullName
                                : (user?.name ?? 'Người dùng'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C47FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'ADMIN',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.label2),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.appleGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Cao: ${healthProvider.currentHeight.toStringAsFixed(0)} cm • Nặng: ${healthProvider.currentWeight.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.appleGreen,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.appleBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'BMI: ${healthProvider.bmi.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.appleBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Admin Dashboard Entry Tile (Chỉ hiển thị khi đăng nhập tài khoản Quản trị viên)
        if (isAdmin) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C47FF), Color(0xFF9B8FFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C47FF).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const AdminDashboardScreen()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.admin_panel_settings_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bảng Điều Khiển Quản Trị (Admin)',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Quản lý thành viên, thống kê hệ thống & báo cáo',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],

        // Settings Options
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Hồ sơ sức khỏe cá nhân
              _SettingTile(
                icon: Icons.badge_rounded,
                iconColor: AppColors.appleGreen,
                title: 'Hồ sơ sức khỏe cá nhân',
                subtitle: 'Chiều cao, cân nặng mục tiêu, mức vận động...',
                onTap: () => _showEditHealthProfileDialog(context, healthProvider),
              ),
              const Divider(indent: 56, height: 1, color: AppColors.separator),

              // Mục tiêu cá nhân
              _SettingTile(
                icon: Icons.flag_rounded,
                iconColor: AppColors.appleOrange,
                title: 'Mục tiêu cá nhân',
                subtitle: 'Nước uống, Giấc ngủ, Vận động hôm nay',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GoalsScreen()),
                  );
                },
              ),
              const Divider(indent: 56, height: 1, color: AppColors.separator),

              // Chế độ tối
              _SettingTile(
                icon: Icons.dark_mode_rounded,
                iconColor: AppColors.applePurple,
                title: 'Chế độ tối (Dark Mode)',
                trailing: Switch(
                  value: isDark,
                  onChanged: (val) => themeProvider.toggleTheme(),
                  activeColor: AppColors.appleGreen,
                ),
              ),
              const Divider(indent: 56, height: 1, color: AppColors.separator),

              // Hướng dẫn sử dụng
              _SettingTile(
                icon: Icons.menu_book_rounded,
                iconColor: AppColors.appleBlue,
                title: 'Hướng dẫn sử dụng',
                subtitle: 'Xem lại màn hình giới thiệu tính năng',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const OnboardingFlowScreen()),
                  );
                },
              ),
              const Divider(indent: 56, height: 1, color: AppColors.separator),

              // Nhắc nhở nước
              _SettingTile(
                icon: Icons.notifications_rounded,
                iconColor: AppColors.appleRed,
                title: 'Nhắc nhở uống nước',
                trailing: Switch(
                  value: _waterReminder,
                  onChanged: (val) => setState(() => _waterReminder = val),
                  activeColor: AppColors.appleGreen,
                ),
              ),
              const Divider(indent: 56, height: 1, color: AppColors.separator),

              // Nhắc nhở ngủ
              _SettingTile(
                icon: Icons.bedtime_rounded,
                iconColor: AppColors.applePurple,
                title: 'Nhắc nhở đi ngủ',
                trailing: Switch(
                  value: _sleepReminder,
                  onChanged: (val) => setState(() => _sleepReminder = val),
                  activeColor: AppColors.appleGreen,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Logout Button
        ElevatedButton.icon(
          onPressed: () async {
            await authProvider.logout();
            healthProvider.clear();
            scheduleProvider.clear();

            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: const Text('ĐĂNG XUẤT',
              style: TextStyle(
                  fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.appleRed.withValues(alpha: 0.15),
            foregroundColor: AppColors.appleRed,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 20),

        // App Version
        const Center(
          child: Text(
            'Health Tracker Pro v2.3.0 (Multi-User & Personalized Schedule)',
            style: TextStyle(fontSize: 12, color: AppColors.label3),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Cài Đặt & Hồ Sơ',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                letterSpacing: -0.5)),
        automaticallyImplyLeading: false,
      ),
      body: isWide
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: body,
              ),
            )
          : body,
    );
  }

  void _showEditHealthProfileDialog(BuildContext context, HealthProvider healthProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final current = healthProvider.healthProfile ??
        HealthProfile(
          userId: healthProvider.userId ?? 1,
          fullName: 'Người dùng',
          height: 170.0,
          currentWeight: 65.0,
          targetWeight: 60.0,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );

    final nameController = TextEditingController(text: current.fullName);
    final heightController = TextEditingController(text: current.height.toStringAsFixed(0));
    final currentWeightController = TextEditingController(text: current.currentWeight.toStringAsFixed(1));
    final targetWeightController = TextEditingController(text: current.targetWeight.toStringAsFixed(1));
    final waterGoalController = TextEditingController(text: current.waterGoal.toString());
    final sleepGoalController = TextEditingController(text: current.sleepGoal.toStringAsFixed(1));

    String selectedGender = current.gender;
    String selectedGoal = current.healthGoal;
    String selectedActivity = current.activityLevel;

    final genderOptions = ['Nam', 'Nữ', 'Khác'];
    final goalOptions = ['Giảm cân', 'Tăng cơ', 'Duy trì vóc dáng', 'Cải thiện sức bền'];
    final activityOptions = ['Ít vận động', 'Vừa phải', 'Năng động', 'Rất cao'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.card1 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Hồ Sơ Sức Khỏe Cá Nhân',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Họ tên
                  const Text('Họ và tên *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Nhập họ tên...',
                      filled: true,
                      fillColor: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Giới tính
                  const Text('Giới tính', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: genderOptions.map((g) {
                      final isSel = selectedGender == g;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Center(child: Text(g)),
                            selected: isSel,
                            selectedColor: AppColors.appleGreen,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : (isDark ? Colors.white : Colors.black87),
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) => setModalState(() => selectedGender = g),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Chiều cao & Cân nặng hiện tại
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Chiều cao (cm)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: heightController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '170',
                                filled: true,
                                fillColor: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Cân nặng hiện tại (kg)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: currentWeightController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: '65.0',
                                filled: true,
                                fillColor: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Cân nặng mục tiêu & Nước mục tiêu
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Mục tiêu cân nặng (kg)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: targetWeightController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: '60.0',
                                filled: true,
                                fillColor: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Mục tiêu nước (ml)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: waterGoalController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '2000',
                                filled: true,
                                fillColor: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Mục tiêu sức khỏe
                  const Text('Mục tiêu sức khỏe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: goalOptions.map((goal) {
                      final isSel = selectedGoal == goal;
                      return ChoiceChip(
                        label: Text(goal),
                        selected: isSel,
                        selectedColor: AppColors.appleGreen,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : (isDark ? Colors.white : Colors.black87),
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (val) => setModalState(() => selectedGoal = goal),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Mức độ vận động
                  const Text('Mức độ vận động', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: activityOptions.map((act) {
                      final isSel = selectedActivity == act;
                      return ChoiceChip(
                        label: Text(act),
                        selected: isSel,
                        selectedColor: AppColors.appleGreen,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : (isDark ? Colors.white : Colors.black87),
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (val) => setModalState(() => selectedActivity = act),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Nút Lưu
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appleGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final height = double.tryParse(heightController.text.trim()) ?? 170.0;
                      final currentWeight = double.tryParse(currentWeightController.text.trim()) ?? 65.0;
                      final targetWeight = double.tryParse(targetWeightController.text.trim()) ?? 60.0;
                      final waterGoal = int.tryParse(waterGoalController.text.trim()) ?? 2000;
                      final sleepGoal = double.tryParse(sleepGoalController.text.trim()) ?? 8.0;

                      final updatedProfile = current.copyWith(
                        fullName: name.isNotEmpty ? name : 'Người dùng',
                        gender: selectedGender,
                        height: height,
                        currentWeight: currentWeight,
                        targetWeight: targetWeight,
                        healthGoal: selectedGoal,
                        activityLevel: selectedActivity,
                        waterGoal: waterGoal,
                        sleepGoal: sleepGoal,
                      );

                      await healthProvider.updateProfile(updatedProfile);

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã cập nhật hồ sơ sức khỏe thành công!'),
                            backgroundColor: AppColors.appleGreen,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'LƯU HỒ SƠ SỨC KHỎE',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: const TextStyle(fontSize: 12, color: AppColors.label2))
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right_rounded, color: AppColors.label3)
              : null),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
