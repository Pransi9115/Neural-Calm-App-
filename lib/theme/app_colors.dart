import 'package:flutter/material.dart';

/// Central palette — matched to neuralcalm.com.
/// Every screen pulls colors from here; nothing hardcodes a hex.
class AppColors {
  static const background = Color(0xFFF7F5FC); // soft lavender-white page
  static const surface = Colors.white; // cards
  static const primary = Color(0xFF7C6FDE); // NeuralCalm lavender
  static const primaryDeep = Color(0xFF4B3F9E); // headings on light lavender
  static const lavenderSoft = Color(0xFFE9E4FA); // fills, rings, chips
  static const ink = Color(0xFF2B2440); // main text
  static const inkMuted = Color(0xFF6F6890); // secondary text
  static const border = Color(0xFFE3DEF2); // hairlines, pill outlines
  static const success = Color(0xFF5FBF9F); // strong category score
  static const warning = Color(0xFFE8A66B); // mid category score
  static const danger = Color(0xFFE07A7A); // low category score
}
