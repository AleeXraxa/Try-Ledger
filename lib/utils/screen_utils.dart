import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenUtils {
  static void init() {
    // Initialize ScreenUtil for responsive design
    // Call this in main.dart
  }

  // Helper methods for responsive sizing
  static double setWidth(double width) => width.w;
  static double setHeight(double height) => height.h;
  static double setSp(double fontSize) => fontSize.sp;
}
