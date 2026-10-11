import 'package:flutter/material.dart';

class AppTheme {
  // ── Primary ──
  static const Color primaryLight = Color.fromRGBO(79, 70, 229, 1.0);
  static const Color primaryDark = Color.fromRGBO(99, 102, 241, 1.0);

  // ── Backgrounds ──
  static const Color backgroundLight = Color.fromRGBO(248, 250, 252, 1.0);
  static const Color backgroundDark = Color.fromRGBO(15, 23, 42, 1.0);

  // ── Surfaces ──
  static const Color surfaceDark = Color.fromRGBO(30, 41, 59, 1.0);

  // ── Borders ──
  static const Color borderLight = Color.fromRGBO(226, 232, 240, 1.0);
  static const Color borderDark = Color.fromRGBO(51, 65, 85, 1.0);

  // ── Input ──
  static const Color inputFillLight = Color.fromRGBO(241, 245, 249, 1.0);

  // ── Focus ──
  static const Color focusBorderDark = Color.fromRGBO(129, 140, 248, 1.0);

  // ── Drag Handle ──
  static const Color dragHandle = Color.fromRGBO(100, 116, 139, 1.0);

  // ── Common ──
  static const Color white = Color.fromRGBO(255, 255, 255, 1.0);
  static const Color black = Color.fromRGBO(0, 0, 0, 1.0);
  static const Color transparent = Color.fromRGBO(0, 0, 0, 0.0);

  // ── Status: Success / Connected ──
  static const Color success = Color.fromRGBO(16, 185, 129, 1.0);
  static const Color successDark = Color.fromRGBO(5, 150, 105, 1.0);

  // ── Status: Warning ──
  static const Color warning = Color.fromRGBO(245, 158, 11, 1.0);
  static const Color warningDark = Color.fromRGBO(146, 64, 14, 1.0);
  static const Color warningMedium = Color.fromRGBO(217, 119, 6, 1.0);
  static const Color warningDeep = Color.fromRGBO(194, 65, 12, 1.0);

  // ── Status: Error ──
  static const Color error = Color.fromRGBO(239, 68, 68, 1.0);
  static const Color errorDark = Color.fromRGBO(220, 38, 38, 1.0);

  // ── Status: Info ──
  static const Color info = Color.fromRGBO(59, 130, 246, 1.0);
  static const Color infoDark = Color.fromRGBO(37, 99, 235, 1.0);

  // ── Deep Orange (slow ping) ──
  static const Color deepOrange = Color.fromRGBO(255, 87, 34, 1.0);

  // ── Hero connected gradient ──
  static const Color connectedGradientStart = Color.fromRGBO(6, 78, 59, 1.0);
  static const Color connectedGradientEnd = Color.fromRGBO(15, 118, 110, 1.0);

  // ── Metrics ──
  static const Color uploadSpeed = Color.fromRGBO(56, 189, 248, 1.0);
  static const Color downloadSpeed = Color.fromRGBO(74, 222, 128, 1.0);

  // ── Protocol badge colors ──
  static const Color protocolVless = Color.fromRGBO(99, 102, 241, 1.0);
  static const Color protocolVmess = Color.fromRGBO(14, 165, 233, 1.0);
  static const Color protocolTrojan = Color.fromRGBO(245, 158, 11, 1.0);
  static const Color protocolShadowsocks = Color.fromRGBO(139, 92, 246, 1.0);
  static const Color protocolHysteria = Color.fromRGBO(236, 72, 153, 1.0);

  // ── Slidable action ──
  static const Color slidableShare = Color.fromRGBO(37, 99, 235, 1.0);
  static const Color slidableDelete = Color.fromRGBO(220, 38, 38, 1.0);

  // ── Settings icon colors ──
  static const Color settingsAppearance = Color.fromRGBO(139, 92, 246, 1.0);
  static const Color settingsLanguage = Color.fromRGBO(59, 130, 246, 1.0);
  static const Color settingsRouting = Color.fromRGBO(245, 158, 11, 1.0);
  static const Color settingsAbout = Color.fromRGBO(16, 185, 129, 1.0);

  // ── QR scan reticle ──
  static const Color qrReticleCorner = Color.fromRGBO(99, 102, 241, 1.0);

  // ─────────────────────────── Light Theme ───────────────────────────

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryLight,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        scrolledUnderElevation: 0,
        backgroundColor: transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  // ─────────────────────────── Dark Theme ───────────────────────────

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDark,
        brightness: Brightness.dark,
        surface: surfaceDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        scrolledUnderElevation: 0,
        backgroundColor: transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderDark),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: focusBorderDark, width: 1.5),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
        dragHandleColor: dragHandle,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
