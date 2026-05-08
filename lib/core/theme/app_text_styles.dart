import 'package:flutter/material.dart';

/// Context-aware text style helpers for TeleDrive.
///
/// These are thin wrappers around [Theme.of(context).textTheme] that give you
/// a shorter, consistent call-site:
///
/// ```dart
/// // Before:
/// style: Theme.of(context).textTheme.headlineSmall
///
/// // After:
/// style: AppTextStyles.headlineSmall(context)
/// ```
///
/// All methods are nullable to match [TextTheme] nullability.
/// Prefer these helpers over ad-hoc [TextStyle] literals so that font changes
/// in [AppTheme] propagate automatically everywhere.
class AppTextStyles {
  AppTextStyles._();

  // ---------------------------------------------------------------------------
  // Display
  // ---------------------------------------------------------------------------

  static TextStyle? displayLarge(BuildContext context) =>
      Theme.of(context).textTheme.displayLarge;

  static TextStyle? displayMedium(BuildContext context) =>
      Theme.of(context).textTheme.displayMedium;

  static TextStyle? displaySmall(BuildContext context) =>
      Theme.of(context).textTheme.displaySmall;

  // ---------------------------------------------------------------------------
  // Headline
  // ---------------------------------------------------------------------------

  static TextStyle? headlineLarge(BuildContext context) =>
      Theme.of(context).textTheme.headlineLarge;

  static TextStyle? headlineMedium(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium;

  static TextStyle? headlineSmall(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall;

  // ---------------------------------------------------------------------------
  // Title
  // ---------------------------------------------------------------------------

  static TextStyle? titleLarge(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge;

  static TextStyle? titleMedium(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium;

  static TextStyle? titleSmall(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall;

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  static TextStyle? bodyLarge(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge;

  static TextStyle? bodyMedium(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium;

  static TextStyle? bodySmall(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall;

  // ---------------------------------------------------------------------------
  // Label
  // ---------------------------------------------------------------------------

  static TextStyle? labelLarge(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge;

  static TextStyle? labelMedium(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium;

  static TextStyle? labelSmall(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall;

  // ---------------------------------------------------------------------------
  // Convenience modifiers
  // ---------------------------------------------------------------------------

  /// Returns [bodyMedium] colored with the theme's primary color.
  static TextStyle? primaryBodyMedium(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      );

  /// Returns [bodySmall] colored with the theme's secondary text color.
  static TextStyle? hintBodySmall(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  /// Returns [labelLarge] colored with the theme's primary color.
  static TextStyle? primaryLabelLarge(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      );

  /// Returns [titleSmall] with a bold weight — useful for list item names.
  static TextStyle? boldTitleSmall(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      );
}
