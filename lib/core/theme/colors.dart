import 'package:flutter/material.dart';

/// App color palette - Dark theme with vibrant green (#4ADE80)
/// Matches mobile app theme exactly
class AppColors {
  AppColors._();

  // Background colors
  static const Color base = Color(0xFF0D0D0D); // Main background
  static const Color surface = Color(0xFF1A1A1A); // Cards/Containers

  // Primary brand color
  static const Color primary = Color(0xFF4ADE80); // Vibrant green
  static const Color onPrimary = Color(0xFF0D0D0D); // Text on primary

  // Text colors
  static const Color textPrimary = Color(0xFFF2F2F2); // Primary text
  static const Color textSecondary = Color(0xFFA3A3A3); // Secondary text

  // Border color
  static const Color borderColor = Color(0xFF262626); // Borders

  // Semantic colors
  static const Color success = Color(0xFF4ADE80); // Same as primary
  static const Color error = Color(0xFFEF4444); // Red for errors
  static const Color warning = Color(0xFFFBBF24); // Yellow for warnings
  static const Color info = Color(0xFF3B82F6); // Blue for info
}
