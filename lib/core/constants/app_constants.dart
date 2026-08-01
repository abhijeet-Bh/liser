import 'package:flutter/widgets.dart';

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  
  static final BorderRadius circularSm = BorderRadius.circular(sm);
  static final BorderRadius circularMd = BorderRadius.circular(md);
  static final BorderRadius circularLg = BorderRadius.circular(lg);
  static final BorderRadius circularXl = BorderRadius.circular(xl);
}

class AppPadding {
  static const EdgeInsets allSm = EdgeInsets.all(8.0);
  static const EdgeInsets allMd = EdgeInsets.all(12.0); // Often 12 is used, wait I'll check my plan
  static const EdgeInsets allLg = EdgeInsets.all(16.0);
  static const EdgeInsets allXl = EdgeInsets.all(24.0);
  static const EdgeInsets allXxl = EdgeInsets.all(32.0);
}

class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}
