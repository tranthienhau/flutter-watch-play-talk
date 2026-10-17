import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    primary: AppColors.accentFill,
    secondary: AppColors.support,
    surface: AppColors.surface,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: AppFonts.body,
    splashFactory: InkSparkle.splashFactory,
    textTheme: const TextTheme(
      displayLarge: AppText.display,
      titleLarge: AppText.title,
      bodyLarge: AppText.body,
      bodyMedium: AppText.body,
      labelLarge: AppText.label,
      bodySmall: AppText.caption,
    ).apply(fontFamily: AppFonts.body),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: const TextStyle(fontFamily: AppFonts.body, color: Colors.white, fontSize: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.accentFill : AppColors.border,
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
  );
}
