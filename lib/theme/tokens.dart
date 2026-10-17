import 'package:flutter/material.dart';

/// Design tokens from design/DESIGN.md (palette P42, lavender + peach).
class AppColors {
  static const background = Color(0xFFF6F4FC);
  static const surface = Color(0xFFFFFFFF);
  static const accent = Color(0xFF9D7BEA);
  static const accentFill = Color(0xFF8165C0);
  static const accentTint = Color(0xFFF1ECFC);
  static const accentPressed = Color(0xFF7159A9);
  static const support = Color(0xFFFFB199);
  static const supportTint = Color(0xFFFFEDE6);
  static const textPrimary = Color(0xFF120C1F);
  static const textSecondary = Color(0xFF4B4360);
  static const textTertiary = Color(0xFF857D99);
  static const border = Color(0xFFE6E1F2);
  static const success = Color(0xFF16A34A);
  static const successTint = Color(0xFFE7F6EC);
  static const warning = Color(0xFFD97706);
  static const warningTint = Color(0xFFFDF1DE);
  static const danger = Color(0xFFDC2626);

  // Game palette (flat 2D art).
  static const gameRed = Color(0xFFE5383B);
  static const gameBlue = Color(0xFF3B82F6);
  static const gameYellow = Color(0xFFFACC15);
}

class AppGradients {
  static const hero = LinearGradient(
    colors: [AppColors.accent, AppColors.support],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const heroDiagonal = LinearGradient(
    colors: [AppColors.accent, AppColors.support],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const pathBackdrop = LinearGradient(
    colors: [Color(0xFFF1ECFC), Color(0xFFFFF3EE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppRadius {
  static const card = 24.0;
  static const control = 16.0;
  static const input = 12.0;
  static const pill = 999.0;
}

class AppShadows {
  static const soft = [
    BoxShadow(color: Color(0x0D120C1F), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x12120C1F), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static List<BoxShadow> glow(Color c) => [
        BoxShadow(color: c.withValues(alpha: 0.35), blurRadius: 28, spreadRadius: 4),
      ];
}

class AppFonts {
  static const body = 'ReadexPro';
  static const display = 'Quicksand';
}

class AppText {
  static const display = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.68,
    color: AppColors.textPrimary,
    height: 1.15,
  );
  static const displayS = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  static const title = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
  );
  static const body = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  static const label = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const caption = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    height: 1.35,
  );
  static const overline = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: AppColors.accentFill,
  );
}
