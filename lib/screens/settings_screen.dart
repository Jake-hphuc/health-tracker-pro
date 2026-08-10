import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'goals_screen.dart';
import 'onboarding_flow_screen.dart';

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
    final isDark = themeProvider.isDarkMode;
    final user = authProvider.currentUser;
    final isWide = AppConstants.isWide(context);
    final cardBg = isDark ? AppColors.card1 : Colors.white;

    Widget body = ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Profile Card
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
                backgroundColor: AppColors.appleGreen.withValues(alpha: 0.15),
                child: const Icon(Icons.person_rounded, size: 36, color: AppColors.appleGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Người dùng',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(fontSize: 13, color: AppColors.label2),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.appleGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Chiều cao: ${user?.height ?? 170} cm',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.appleGreen),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

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
              // Dark Mode Switch
              SwitchListTile(
                title: const Text('Chế độ Tối (Dark Mode) 🌙', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: const Text('Tối ưu mắt & tiết kiệm pin', style: TextStyle(fontSize: 12, color: AppColors.label2)),
                value: isDark,
                activeColor: AppColors.appleGreen,
                onChanged: (val) => themeProvider.toggleTheme(val),
              ),
              Divider(height: 1, color: isDark ? AppColors.separator : Colors.grey.shade200),

              // Health Profile Setup Flow
              ListTile(
                leading: const Icon(Icons.assignment_ind_rounded, color: AppColors.appleBlue, size: 22),
                title: const Text('Thiết lập Hồ sơ Sức khỏe 📋', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: const Text('Quy trình 4 bước thiết lập chỉ số & mục tiêu', style: TextStyle(fontSize: 12, color: AppColors.label2)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.label2),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OnboardingFlowScreen(isEditMode: true)),
                  );
                },
              ),
              Divider(height: 1, color: isDark ? AppColors.separator : Colors.grey.shade200),

              // Goals Navigation
              ListTile(
                leading: const Icon(Icons.flag_rounded, color: AppColors.appleGreen, size: 22),
                title: const Text('Thiết lập Mục tiêu Cá nhân 🎯', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.label2),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GoalsScreen()),
                  );
                },
              ),
              Divider(height: 1, color: isDark ? AppColors.separator : Colors.grey.shade200),

              // Water Notification Toggle
              SwitchListTile(
                title: const Text('Nhắc nhở Uống nước 💧', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: const Text('Thông báo mỗi 2 tiếng', style: TextStyle(fontSize: 12, color: AppColors.label2)),
                value: _waterReminder,
                activeColor: AppColors.appleBlue,
                onChanged: (val) {
                  setState(() => _waterReminder = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(val ? 'Đã bật nhắc uống nước 💧' : 'Đã tắt nhắc uống nước'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
              Divider(height: 1, color: isDark ? AppColors.separator : Colors.grey.shade200),

              // Sleep Notification Toggle
              SwitchListTile(
                title: const Text('Nhắc nhở Đi ngủ 😴', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: const Text('Thông báo lúc 22:30 mỗi tối', style: TextStyle(fontSize: 12, color: AppColors.label2)),
                value: _sleepReminder,
                activeColor: AppColors.applePurple,
                onChanged: (val) {
                  setState(() => _sleepReminder = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(val ? 'Đã bật nhắc đi ngủ 😴' : 'Đã tắt nhắc đi ngủ'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Logout Button
        ElevatedButton.icon(
          onPressed: () async {
            await authProvider.logout();
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: const Text('ĐĂNG XUẤT TÀI KHOẢN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.appleRed.withValues(alpha: 0.15),
            foregroundColor: AppColors.appleRed,
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 32),

        // App Footer Info
        const Center(
          child: Text(
            'Health Tracker Pro v1.0.0\nLập trình Thiết bị Di động Q2',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.label3, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Cài đặt ⚙️'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: isWide
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: body,
              ),
            )
          : body,
    );
  }
}
