import 'package:flutter/material.dart';

class ResponsiveHelper {
  ResponsiveHelper._();

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;
  static const double desktopBreakpoint = 1800;

  // Check device type
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Get responsive value based on screen size
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  // Get number of columns for grid based on screen size
  static int getGridColumns(BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 4,
  }) {
    if (isDesktop(context)) {
      return desktopColumns;
    } else if (isTablet(context)) {
      return tabletColumns;
    } else {
      return mobileColumns;
    }
  }

  // Get padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    return getResponsiveValue(
      context: context,
      mobile: mobile ?? const EdgeInsets.all(16),
      tablet: tablet ?? const EdgeInsets.all(24),
      desktop: desktop ?? const EdgeInsets.all(32),
    );
  }

  // Get font size based on screen size
  static double getResponsiveFontSize(BuildContext context, {
    required double baseFontSize,
    double mobileScale = 0.9,
    double tabletScale = 1.0,
    double desktopScale = 1.1,
  }) {
    if (isDesktop(context)) {
      return baseFontSize * desktopScale;
    } else if (isTablet(context)) {
      return baseFontSize * tabletScale;
    } else {
      return baseFontSize * mobileScale;
    }
  }
}
