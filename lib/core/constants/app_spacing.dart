import 'package:flutter/material.dart';

import 'app_constants.dart';

/// Centralized spacing scale for TeleDrive.
///
/// Use these constants for all padding, margin, and gap values
/// instead of ad-hoc magic numbers.
///
/// Scale: 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48
class AppSpacing {
  AppSpacing._();

  // ---------------------------------------------------------------------------
  // Raw values (use with EdgeInsets / SizedBox / Padding)
  // ---------------------------------------------------------------------------

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;

  // ---------------------------------------------------------------------------
  // Vertical gap widgets  (drop-in replacement for SizedBox(height: N))
  // ---------------------------------------------------------------------------

  static const Widget gapXXS = SizedBox(height: xxs);
  static const Widget gapXS = SizedBox(height: xs);
  static const Widget gapSM = SizedBox(height: sm);
  static const Widget gapMD = SizedBox(height: md);
  static const Widget gapLG = SizedBox(height: lg);
  static const Widget gapXL = SizedBox(height: xl);
  static const Widget gapXXL = SizedBox(height: xxl);
  static const Widget gapXXXL = SizedBox(height: xxxl);

  // ---------------------------------------------------------------------------
  // Horizontal gap widgets  (drop-in replacement for SizedBox(width: N))
  // ---------------------------------------------------------------------------

  static const Widget hGapXXS = SizedBox(width: xxs);
  static const Widget hGapXS = SizedBox(width: xs);
  static const Widget hGapSM = SizedBox(width: sm);
  static const Widget hGapMD = SizedBox(width: md);
  static const Widget hGapLG = SizedBox(width: lg);
  static const Widget hGapXL = SizedBox(width: xl);

  // ---------------------------------------------------------------------------
  // Common EdgeInsets helpers
  // ---------------------------------------------------------------------------

  /// Uniform padding on all sides.
  static const EdgeInsets allXXS = EdgeInsets.all(xxs);
  static const EdgeInsets allXS = EdgeInsets.all(xs);
  static const EdgeInsets allSM = EdgeInsets.all(sm);
  static const EdgeInsets allMD = EdgeInsets.all(md);
  static const EdgeInsets allLG = EdgeInsets.all(lg);
  static const EdgeInsets allXL = EdgeInsets.all(xl);
  static const EdgeInsets allXXL = EdgeInsets.all(xxl);

  /// Standard screen-level padding (24 on all sides).
  static const EdgeInsets screen = EdgeInsets.all(xl);

  /// Proposal-compatible names for common padding helpers.
  static const EdgeInsets padSM = allXS;
  static const EdgeInsets padMD = allSM;
  static const EdgeInsets padLG = allMD;
  static const EdgeInsets padXXL = allXL;
  static const EdgeInsets padH = hMD;
  static const EdgeInsets padHXXL = hXL;
  static const EdgeInsets padScreen = screen;

  /// Horizontal padding only.
  static const EdgeInsets hMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets hXL = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets hXXL = EdgeInsets.symmetric(horizontal: xxl);

  /// Vertical padding only.
  static const EdgeInsets vXXS = EdgeInsets.symmetric(vertical: xxs);
  static const EdgeInsets vXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets vSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets vMD = EdgeInsets.symmetric(vertical: md);

  /// Horizontal + vertical combinations (used by list/card items).
  static const EdgeInsets hMdVXxs =
      EdgeInsets.symmetric(horizontal: md, vertical: xxs);
  static const EdgeInsets hMdVXs =
      EdgeInsets.symmetric(horizontal: md, vertical: xs);
  static const EdgeInsets hMdVSm =
      EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets hXlVMd =
      EdgeInsets.symmetric(horizontal: xl, vertical: md);
  static const EdgeInsets hXlVXxl =
      EdgeInsets.symmetric(horizontal: xl, vertical: xxl);
}

/// Centralized border-radius scale for TeleDrive.
class AppRadius {
  AppRadius._();

  // ---------------------------------------------------------------------------
  // Raw values
  // ---------------------------------------------------------------------------

  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double chip = 18;
  static const double card = AppConstants.cardBorderRadius;
  static const double item = AppConstants.itemBorderRadius;
  static const double full = 999; // pill / stadium

  // ---------------------------------------------------------------------------
  // BorderRadius helpers
  // ---------------------------------------------------------------------------

  static const BorderRadius xsBR = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smBR = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBR = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBR = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlBR = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlBR = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius chipBR = BorderRadius.all(Radius.circular(chip));
  static const BorderRadius cardBR = BorderRadius.all(Radius.circular(card));
  static const BorderRadius itemBR = BorderRadius.all(Radius.circular(item));
  static const BorderRadius fullBR = BorderRadius.all(Radius.circular(full));

  /// Rounded only on the top (for bottom sheets).
  static const BorderRadius topMD =
      BorderRadius.vertical(top: Radius.circular(md));

  // ---------------------------------------------------------------------------
  // RRect helpers  (use with ClipRRect / Material)
  // ---------------------------------------------------------------------------

  static RRect toRRect(double r, Rect rect) =>
      RRect.fromRectAndRadius(rect, Radius.circular(r));
}
