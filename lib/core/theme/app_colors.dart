import 'package:flutter/material.dart';

/// App-wide color palette using HSL-tuned harmonious colors.
class AppColors {
  AppColors._();

  // === Primary — Deep Indigo Blue ===
  static const Color primary = Color(0xFF4F6AF5);
  static const Color primaryLight = Color(0xFF7B93FF);
  static const Color primaryDark = Color(0xFF2D4BD4);
  static const Color primaryContainer = Color(0xFF1A2A7A);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // === Secondary — Teal Accent ===
  static const Color secondary = Color(0xFF00C9A7);
  static const Color secondaryLight = Color(0xFF4DDDCA);
  static const Color secondaryDark = Color(0xFF00967D);
  static const Color secondaryContainer = Color(0xFF003D35);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // === Tertiary — Warm Amber ===
  static const Color tertiary = Color(0xFFFFB347);
  static const Color tertiaryContainer = Color(0xFF4A3000);

  // === Surface Colors — Dark Mode ===
  static const Color surfaceDark = Color(0xFF0F1117);
  static const Color surfaceVariantDark = Color(0xFF1A1D2E);
  static const Color cardDark = Color(0xFF1E2235);
  static const Color cardDarkAlt = Color(0xFF252840);
  static const Color dividerDark = Color(0xFF2A2D40);

  // === Surface Colors — Light Mode ===
  static const Color surfaceLight = Color(0xFFF4F5FB);
  static const Color surfaceVariantLight = Color(0xFFEBEDF8);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardLightAlt = Color(0xFFF0F1FA);
  static const Color dividerLight = Color(0xFFE0E2F0);

  // === Text Colors — Dark Mode ===
  static const Color textPrimaryDark = Color(0xFFF0F2FF);
  static const Color textSecondaryDark = Color(0xFFABADC8);
  static const Color textHintDark = Color(0xFF6B6E88);

  // === Text Colors — Light Mode ===
  static const Color textPrimaryLight = Color(0xFF0E1040);
  static const Color textSecondaryLight = Color(0xFF4A4E72);
  static const Color textHintLight = Color(0xFF9B9EB8);

  // === Status Colors ===
  static const Color success = Color(0xFF00C9A7);
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF5C7A);
  static const Color info = Color(0xFF4F6AF5);

  // === File Type Colors ===
  static const Color fileImage = Color(0xFF4F6AF5);
  static const Color fileVideo = Color(0xFF9B59B6);
  static const Color fileAudio = Color(0xFF00C9A7);
  static const Color filePdf = Color(0xFFFF5C7A);
  static const Color fileDocument = Color(0xFF3498DB);
  static const Color fileArchive = Color(0xFFFFB347);
  static const Color fileOther = Color(0xFF95A5A6);

  // === Gradient Definitions ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F6AF5), Color(0xFF7B4CF5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0F1117), Color(0xFF1A1D2E), Color(0xFF0F1117)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E2235), Color(0xFF252840)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color fileTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return fileImage;
      case 'video':
        return fileVideo;
      case 'audio':
        return fileAudio;
      case 'pdf':
        return filePdf;
      case 'document':
        return fileDocument;
      case 'archive':
        return fileArchive;
      default:
        return fileOther;
    }
  }
}
