import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
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
    final isDark = themeProvider.isDarkMode;
    final user = authProvider.currentUser;
    final isAdmin = authProvider.isAdmin;
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
                        Text(
                          user?.name ?? 'Người dùng',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C47FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'ADMIN',
                              style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ],
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
                        color: (isAdmin ? const Color(0xFF6C47FF) : AppColors.appleGreen).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isAdmin ? '👑 Quản trị viên hệ thống' : 'Chiều cao: ${user?.height ?? 170} cm',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isAdmin ? const Color(0xFF6C47FF) : AppColors.appleGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Admin Dashboard Entry Tile (Accessible for Admin, or visible as Admin entry)
        Container(
          margin: const EdgeInsets.only(bottom: 20),
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
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
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
                      child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bảng Điều Khiển Admin',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Quản lý người dùng, doanh thu quảng cáo & KPI',
                            style: TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ),

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
              _SettingTile(
                icon: Icons.dark_mode_rounded,
                iconColor: AppColors.applePurple,
                title: 'Chế độ tối (Dark Mode)',
                trailing: Switch(
                  value: isDark,
                  onChanged: (val) => themeProvider.toggleTheme(val),
                  activeColor: AppColors.appleGreen,
                ),
              ),
              const Divider(indent: 56, height: 1, color: AppColors.separator),
              _SettingTile(
                icon: Icons.flag_rounded,
                iconColor: AppColors.appleOrange,
                title: 'Mục tiêu cá nhân',
                subtitle: 'Nước, Giấc ngủ, Cân nặng, Vận động',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GoalsScreen()),
                  );
                },
              ),
              const Divider(indent: 56, height: 1, color: AppColors.separator),
              _SettingTile(
                icon: Icons.menu_book_rounded,
                iconColor: AppColors.appleBlue,
                title: 'Hướng dẫn sử dụng',
                subtitle: 'Xem lại màn hình giới thiệu 4 bước',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
                  );
                },
              ),
              const Divider(indent: 56, height: 1, color: AppColors.separator),
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
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: const Text('ĐĂNG XUẤT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.appleRed.withValues(alpha: 0.15),
            foregroundColor: AppColors.appleRed,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 20),

        // App Version
        const Center(
          child: Text(
            'Health Tracker Pro v2.1.0 (Apple UI Edition)',
            style: TextStyle(fontSize: 12, color: AppColors.label3),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Cài Đặt', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.5)),
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
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.label2))
          : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, color: AppColors.label3) : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}