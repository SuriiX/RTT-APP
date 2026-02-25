import 'package:flutter/material.dart';

/// Colores corporativos de RadioTeleTaxi.
abstract final class RttColors {
  static const Color red = Color(0xFFE53935);
  static const Color darkRed = Color(0xFFB71C1C);
  static const Color accent = Color(0xFFD81B60);
  static const Color background = Color(0xFFF3F3F3);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color footerGrey = Color(0xFF4A4A4A);
}

/// ThemeData principal de la app RTT.
ThemeData rttTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: RttColors.red,
      primary: RttColors.red,
      onPrimary: Colors.white,
      surface: RttColors.surface,
      onSurface: RttColors.textPrimary,
    ),
    scaffoldBackgroundColor: RttColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: RttColors.red,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: RttColors.red,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: RttColors.red,
        side: const BorderSide(color: RttColors.red),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: RttColors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: RttColors.divider,
      thickness: 1,
      space: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return RttColors.red;
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return RttColors.red.withAlpha(80);
        }
        return Colors.grey.withAlpha(80);
      }),
    ),
  );
}
