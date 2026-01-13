import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppStyles {
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 12,
        offset: Offset(0, 4),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.02),
        blurRadius: 24,
        offset: Offset(0, 8),
        spreadRadius: 0,
      ),
    ],
    border: Border.all(color: AppColors.neutral.withOpacity(0.08), width: 1),
  );

  static TextStyle headingStyle = AppFonts.poppinsBold.copyWith(
    fontSize: 24,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyStyle = AppFonts.poppinsRegular.copyWith(
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    textStyle: AppFonts.poppinsBold,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
