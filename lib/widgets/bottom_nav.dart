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
    _NavItem(icon: Icons.square_rounded,          label: 'Tá»•ng quan', activeColor: AppColors.appleGreen),
    _NavItem(icon: Icons.bolt_rounded,             label: 'Táº­p luyá»‡n', activeColor: AppColors.appleRed),
    _NavItem(icon: Icons.water_drop_rounded,       label: 'NÆ°á»›c',      activeColor: AppColors.appleBlue),
    _NavItem(icon: Icons.bedtime_rounded,          label: 'Giáº¥c ngá»§', activeColor: AppColors.applePurple),
    _NavItem(icon: Icons.monitor_weight_rounded,   label: 'CĂ¢n náº·ng', activeColor: AppColors.appleOrange),
    _NavItem(icon: Icons.directions_run_rounded,   label: 'Váº­n Ä‘á»™ng', activeColor: AppColors.appleRed),
    _NavItem(icon: Icons.emoji_events_rounded,     label: 'Thá»­ thĂ¡ch', activeColor: AppColors.appleYellow),
    _NavItem(icon: Icons.stars_rounded,            label: 'KOLs',     activeColor: AppColors.appleGreen),
    _NavItem(icon: Icons.lightbulb_rounded,        label: 'Máº¹o hay',  activeColor: AppColors.appleTeal),
    _NavItem(icon: Icons.card_giftcard_rounded,    label: 'Äá»•i QuĂ ',  activeColor: AppColors.appleRed),
    _NavItem(icon: Icons.bar_chart_rounded,        label: 'Thá»‘ng kĂª', activeColor: AppColors.appleTeal),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.card1.withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.94),
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
          height: 60,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item      = _items[i];
              final isActive  = currentIndex == i;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale:    isActive ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            item.icon,
                            size:  20,
                            color: isActive
                                ? item.activeColor
                                : (isDark ? AppColors.label3 : const Color(0xFFAEAEB2)),
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          style: TextStyle(
                            fontSize:   8.5,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                            color: isActive
                                ? item.activeColor
                                : (isDark ? AppColors.label3 : const Color(0xFFAEAEB2)),
                            letterSpacing: 0.1,
                          ),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String   label;
  final Color    activeColor;
  const _NavItem({required this.icon, required this.label, required this.activeColor});
}
