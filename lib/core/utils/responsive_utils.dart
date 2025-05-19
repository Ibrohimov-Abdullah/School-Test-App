// lib/core/utils/responsive_util.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveUtil {
  // Function to initialize ScreenUtil in the app
  static void init(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(360, 690), // Base design size for mobile
      minTextAdapt: true,
      splitScreenMode: true,
    );
  }

  // Extension methods for sizing
  static double get screenWidth => ScreenUtil().screenWidth;
  static double get screenHeight => ScreenUtil().screenHeight;

  // Padding and margin values
  static double get smallPadding => ResponsiveNumExtensions(8).w;
  static double get mediumPadding => ResponsiveNumExtensions(16).w;
  static double get largePadding => ResponsiveNumExtensions(24).w;

  // Font sizes
  static double get smallText => ResponsiveNumExtensions(12).sp;
  static double get bodyText => ResponsiveNumExtensions(14).sp;
  static double get titleText => ResponsiveNumExtensions(18).sp;
  static double get headingText => ResponsiveNumExtensions(24).sp;

  // Icon sizes
  static double get smallIcon => ResponsiveNumExtensions(16).w;
  static double get mediumIcon => ResponsiveNumExtensions(24).w;
  static double get largeIcon => ResponsiveNumExtensions(32).w;

  // Border radius
  static double get smallRadius => ResponsiveNumExtensions(4).r;
  static double get mediumRadius => ResponsiveNumExtensions(8).r;
  static double get largeRadius => ResponsiveNumExtensions(16).r;

  // Helpers for responsive conditions
  static bool get isPhone => screenWidth < 600;
  static bool get isTablet => screenWidth >= 600 && screenWidth < 900;
  static bool get isDesktop => screenWidth >= 900;

  // Get appropriate padding based on screen size
  static EdgeInsets get screenPadding {
    if (isPhone) {
      return REdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else if (isTablet) {
      return REdgeInsets.symmetric(horizontal: 24, vertical: 12);
    } else {
      return REdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  // Get appropriate max width for containers based on screen size
  static double get maxContainerWidth {
    if (isPhone) {
      return double.infinity;
    } else if (isTablet) {
      return ResponsiveNumExtensions(560).w;
    } else {
      return ResponsiveNumExtensions(800).w;
    }
  }
}

// Extension methods for easier access
extension ResponsiveNumExtensions on num {
  double get w => ScreenUtil().setWidth(this);
  double get h => ScreenUtil().setHeight(this);
  double get r => ScreenUtil().radius(this);
  double get sp => ScreenUtil().setSp(this);

  SizedBox get vSpace => SizedBox(height: ResponsiveNumExtensions(this).h);
  SizedBox get hSpace => SizedBox(width: ResponsiveNumExtensions(this).w);
}

// Extension methods for widget sizing
extension ResponsiveWidgetExtensions on Widget {
  Widget paddingAll(double padding) => Padding(
    padding: REdgeInsets.all(padding),
    child: this,
  );

  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) => Padding(
    padding: REdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
    child: this,
  );

  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      Padding(
        padding: REdgeInsets.only(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
        ),
        child: this,
      );

  Widget get center => Center(child: this);

  Widget expanded({int flex = 1}) => Expanded(
    flex: flex,
    child: this,
  );
}