import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/health_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/challenge_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const HealthTrackerApp());
}

class HealthTrackerApp extends StatelessWidget {
  const HealthTrackerApp({super.key});

  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.beVietnamProTextTheme(base).copyWith(
      displayLarge: GoogleFonts.beVietnamPro(
        fontSize: 57, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineLarge: GoogleFonts.beVietnamPro(
        fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineMedium: GoogleFonts.beVietnamPro(
        fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleLarge: GoogleFonts.beVietnamPro(
        fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.2),
      titleMedium: GoogleFonts.beVietnamPro(
        fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.beVietnamPro(
        fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.beVietnamPro(
        fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: GoogleFonts.beVietnamPro(
        fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.beVietnamPro(
        fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
    );
  }

  ThemeData _darkTheme() => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: GoogleFonts.beVietnamPro().fontFamily,
    scaffoldBackgroundColor: AppColors.blackBg,
    primaryColor: AppColors.appleGreen,
    colorScheme: const ColorScheme.dark(
      primary:   AppColors.appleGreen,
      secondary: AppColors.appleBlue,
      tertiary:  AppColors.appleRed,
      surface:   AppColors.card1,
      onSurface: AppColors.white,
      outline:   AppColors.separator,
    ),
    cardTheme: CardThemeData(
      color:        AppColors.card1,
      elevation:    0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor:     Colors.transparent,
      elevation:           0,
      scrolledUnderElevation: 0,
      centerTitle:         false,
      titleTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: AppColors.appleBlue),
    ),
    textTheme: _buildTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor:       AppColors.white,
      displayColor:    AppColors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:  AppColors.appleBlue,
        foregroundColor:  Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.appleBlue, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.label2),
    ),
  );

  ThemeData _lightTheme() => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: GoogleFonts.beVietnamPro().fontFamily,
    scaffoldBackgroundColor: AppColors.lightBg,
    primaryColor: AppColors.appleGreen,
    colorScheme: const ColorScheme.light(
      primary:   AppColors.appleGreen,
      secondary: AppColors.appleBlue,
      tertiary:  AppColors.appleRed,
      surface:   Colors.white,
    ),
    cardTheme: CardThemeData(
      color:     Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor:     Colors.transparent,
      elevation:           0,
      scrolledUnderElevation: 0,
      centerTitle:         false,
    ),
    textTheme: _buildTextTheme(ThemeData.light().textTheme),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF2F2F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.appleBlue, width: 1.5),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => ChallengeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Health Tracker Pro',
            debugShowCheckedModeBanner: false,
            theme:      _lightTheme(),
            darkTheme:  _darkTheme(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
