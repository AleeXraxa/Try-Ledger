import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppStyles {
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
    ],
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
