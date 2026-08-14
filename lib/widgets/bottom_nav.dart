import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.dashboard_rounded,      label: 'Tổng quan', activeColor: AppColors.appleGreen),
    _NavItem(icon: Icons.restaurant_rounded,     label: 'Ăn uống',   activeColor: AppColors.appleOrange),
    _NavItem(icon: Icons.bolt_rounded,           label: 'Tập luyện', activeColor: AppColors.appleRed),
    _NavItem(icon: Icons.water_drop_rounded,     label: 'Nước',      activeColor: AppColors.appleBlue),
    _NavItem(icon: Icons.bedtime_rounded,        label: 'Giấc ngủ', activeColor: AppColors.applePurple),
    _NavItem(icon: Icons.monitor_weight_rounded, label: 'Cân nặng', activeColor: AppColors.appleOrange),
    _NavItem(icon: Icons.directions_run_rounded, label: 'Vận động', activeColor: AppColors.appleRed),
    _NavItem(icon: Icons.emoji_events_rounded,   label: 'Thử thách', activeColor: AppColors.appleYellow),
    _NavItem(icon: Icons.stars_rounded,          label: 'KOLs',     activeColor: AppColors.appleGreen),
    _NavItem(icon: Icons.lightbulb_rounded,      label: 'Mẹo hay',  activeColor: AppColors.appleTeal),
    _NavItem(icon: Icons.card_giftcard_rounded,  label: 'Đổi Quà',  activeColor: AppColors.appleRed),
    _NavItem(icon: Icons.bar_chart_rounded,      label: 'Thống kê', activeColor: AppColors.appleTeal),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.card1.withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.separator : const Color(0xFFE5E5EA),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _items.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, i) {
              final item = _items[i];
              final isActive = currentIndex == i;

              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? item.activeColor.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: isActive
                            ? item.activeColor
                            : (isDark ? AppColors.label3 : const Color(0xFFAEAEB2)),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                          color: isActive
                              ? item.activeColor
                              : (isDark ? AppColors.label3 : const Color(0xFF8E8E93)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Color activeColor;
  const _NavItem({required this.icon, required this.label, required this.activeColor});
}
