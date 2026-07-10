import 'package:flutter/material.dart';

/// Design system — extracted from the NeuralCalm backend (coach tool)
/// and the approved v5 mockup. No screen hardcodes a hex.
class AppColors {
  static const navy = Color(0xFF1E1148);        // chrome: bars, letterhead
  static const background = Color(0xFFF5F2FC);  // light lavender pages
  static const surface = Colors.white;          // cards

  /// Soft card shadow from the approved mockup (rgba(30,17,72,.10)).
  static const cardShadow = [
    BoxShadow(
        color: Color(0x1A1E1148), blurRadius: 14, offset: Offset(0, 3)),
  ];
  static const purple = Color(0xFF7E5CE6);      // primary: buttons, accents
  static const purpleDeep = Color(0xFF3A1F82);
  static const purpleLight = Color(0xFF9B7ED4); // "Calm" in the wordmark
  static const purplePale = Color(0xFFE4DBF9);  // fills, rings, chips
  static const border = Color(0xFFDFD6F4);
  static const ink = Color(0xFF1E1148);
  static const muted = Color(0xFF6B5F8A);
  static const onNavy = Color(0xFFC0B4DC);      // secondary text on navy
  static const green = Color(0xFF16A34A);
  static const greenPale = Color(0xFFDCFCE7);
  static const amber = Color(0xFFD97706);
  static const amberPale = Color(0xFFFEF3C7);
  static const red = Color(0xFFDC2626);
  static const redPale = Color(0xFFFEE2E2);
  static const redDark = Color(0xFF991B1B);
}
