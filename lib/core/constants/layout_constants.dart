import 'package:flutter/widgets.dart';

class LayoutConstants {
  /// The numeric value for the padding at the bottom of standard pages.
  static const double _pageBottomPaddingValue = 110.0;

  /// Padding applied to the bottom of views to prevent content from being obscured
  /// by the floating nav bar and mini player.
  static const EdgeInsets pageBottomPadding = EdgeInsets.only(bottom: _pageBottomPaddingValue);

  /// Standard padding for list views, including top padding and the standard bottom padding.
  static const EdgeInsets standardListPadding = EdgeInsets.only(top: 8.0, bottom: _pageBottomPaddingValue);
}
