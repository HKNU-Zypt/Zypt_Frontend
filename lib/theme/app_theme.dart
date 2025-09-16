import 'package:flutter/material.dart';

/// Centralized application theme configuration.
class AppTheme {
  /// 브랜드 시드 컬러 (현재 앱에서 주로 사용 중인 초록색 톤)
  static const Color brandSeedColor = Color(0xFF6BAB93);

  /// 라이트 테마
  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: brandSeedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: scheme,
      primaryColor: brandSeedColor,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 다크 테마 (필요 시 사용)
  static ThemeData dark() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: brandSeedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      colorScheme: scheme,
      primaryColor: brandSeedColor,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
