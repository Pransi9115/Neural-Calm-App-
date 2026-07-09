import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// The circular logo glyph — purple disc, white pulse mark.
class GlyphLogo extends StatelessWidget {
  final double size;
  const GlyphLogo({super.key, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration:
          const BoxDecoration(color: AppColors.purple, shape: BoxShape.circle),
      child: Stack(children: [
        Positioned(
          left: size * 0.23,
          top: size * 0.20,
          child: Container(
            width: size * 0.30,
            height: size * 0.60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size * 0.30),
                bottomLeft: Radius.circular(size * 0.30),
              ),
            ),
          ),
        ),
        Positioned(
          right: size * 0.18,
          top: size * 0.40,
          child: Container(
            width: size * 0.22,
            height: size * 0.22,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ]),
    );
  }
}

/// The NeuralCalm™ wordmark: white "Neural" + purple "Calm".
/// Always place on navy (top bar, hero band, letterhead).
class Wordmark extends StatelessWidget {
  final double fontSize;
  final bool withGlyph;
  const Wordmark({super.key, this.fontSize = 21, this.withGlyph = true});

  @override
  Widget build(BuildContext context) {
    final text = Text.rich(TextSpan(children: [
      TextSpan(
          text: 'Neural',
          style: cormorant(
              size: fontSize, weight: FontWeight.w700, color: Colors.white)),
      TextSpan(
          text: 'Calm',
          style: cormorant(
              size: fontSize,
              weight: FontWeight.w700,
              color: AppColors.purpleLight)),
      TextSpan(
          text: '™',
          style: TextStyle(
              fontSize: fontSize * 0.42,
              color: Colors.white,
              fontWeight: FontWeight.w600)),
    ]));
    if (!withGlyph) return text;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      GlyphLogo(size: fontSize * 1.35),
      SizedBox(width: fontSize * 0.42),
      text,
    ]);
  }
}
