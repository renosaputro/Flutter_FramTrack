import 'package:flutter/material.dart';
import 'app_colors.dart';

class FtColors {
  FtColors._();

  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.card;

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.surface;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.textPrimary;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.textSecondary;

  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? AppColors.darkElevated : AppColors.divider;

  static Color elevated(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? AppColors.darkElevated : Colors.white;

  static Color primarySurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1B3A1E) : AppColors.primarySurface;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
