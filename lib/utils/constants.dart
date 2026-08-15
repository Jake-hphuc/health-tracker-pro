import 'package:flutter/material.dart';

class AppColors {
  // === Apple Core Colors ===
  static const Color appleRed    = Color(0xFFFF375F);   // Activity / Move ring
  static const Color appleGreen  = Color(0xFF32D74B);   // Exercise / Stand ring
  static const Color appleBlue   = Color(0xFF0A84FF);   // Water / Hydration
  static const Color applePurple = Color(0xFFBF5AF2);   // Sleep
  static const Color appleOrange = Color(0xFFFF9F0A);   // Weight / BMI
  static const Color appleYellow = Color(0xFFFFD60A);   // Goals
  static const Color appleTeal   = Color(0xFF5AC8FA);   // Stand / extra

  // === Apple Backgrounds ===
  static const Color blackBg     = Color(0xFF000000);   // Screen background
  static const Color card1       = Color(0xFF1C1C1E);   // Card level 1
  static const Color card2       = Color(0xFF2C2C2E);   // Card level 2
  static const Color card3       = Color(0xFF3A3A3C);   // Card level 3
  static const Color separator   = Color(0xFF38383A);   // Separator lines

  // === Text Colors ===
  static const Color white       = Color(0xFFFFFFFF);
  static const Color label1      = Color(0xFFFFFFFF);   // Primary label
  static const Color label2      = Color(0xFF8E8E93);   // Secondary label
  static const Color label3      = Color(0xFF636366);   // Tertiary label
  static const Color label4      = Color(0xFF48484A);   // Quaternary label

  // === Gradients ===
  static const List<Color> redRing    = [Color(0xFFFF375F), Color(0xFFFF6B9D)];
  static const List<Color> greenRing  = [Color(0xFF32D74B), Color(0xFF30D158)];
  static const List<Color> blueRing   = [Color(0xFF0A84FF), Color(0xFF5AC8FA)];
  static const List<Color> purpleRing = [Color(0xFFBF5AF2), Color(0xFFDA8FFF)];
  static const List<Color> orangeRing = [Color(0xFFFF9F0A), Color(0xFFFFCC02)];

  // Legacy aliases
  static const Color primaryGreen   = appleGreen;
  static const Color primaryDark    = Color(0xFF25A244);
  static const Color primaryLight   = Color(0xFF30D158);
  static const Color waterBlue      = appleBlue;
  static const Color waterBlueDark  = Color(0xFF006EE6);
  static const Color sleepPurple    = applePurple;
  static const Color sleepPurpleDark = Color(0xFF9B3DD4);
  static const Color weightOrange   = appleOrange;
  static const Color weightOrangeDark = Color(0xFFE68900);
  static const Color activityRed    = appleRed;
  static const Color activityRedDark = Color(0xFFD4002D);
  static const Color lightBg        = Color(0xFFF2F2F7);
  static const Color darkBg         = blackBg;
  static const Color subtitleLight  = Color(0xFF6E6E73);
}

class AppConstants {
  static const List<String> activityTypes = [
    'Đi bộ',
    'Chạy bộ',
    'Đạp xe',
    'Bơi lội',
    'Tập tạ',
    'Gym',
    'Yoga',
    'HIIT',
    'Leo núi',
    'Bóng rổ',
    'Bóng đá',
    'Cầu lông',
    'Khác',
  ];

  static const Map<String, IconData> activityIcons = {
    'Đi bộ': Icons.directions_walk_rounded,
    'Chạy bộ': Icons.directions_run_rounded,
    'Đạp xe': Icons.pedal_bike_rounded,
    'Bơi lội': Icons.pool_rounded,
    'Tập tạ': Icons.fitness_center_rounded,
    'Gym': Icons.fitness_center_rounded,
    'Yoga': Icons.self_improvement_rounded,
    'HIIT': Icons.local_fire_department_rounded,
    'Leo núi': Icons.landscape_rounded,
    'Bóng rổ': Icons.sports_basketball_rounded,
    'Bóng đá': Icons.sports_soccer_rounded,
    'Cầu lông': Icons.sports_tennis_rounded,
    'Khác': Icons.more_horiz_rounded,
  };

  static const List<String> sleepQuality = [
    'Rất kém',
    'Kém',
    'Bình thường',
    'Tốt',
    'Rất tốt',
  ];

  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;
}
