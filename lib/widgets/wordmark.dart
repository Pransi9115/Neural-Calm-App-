import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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

/// The Neural Calm wordmark.
///
/// Now renders the supplied brand PNG (assets/logo/neural-calm.png)
/// instead of drawing the name with text styles.
///
/// [fontSize] is kept so existing call sites still compile — it sets
/// the rendered height (the artwork is 220x70, so height drives width).
class Wordmark extends StatelessWidget {
  final double fontSize;
  final bool withGlyph;
  const Wordmark({super.key, this.fontSize = 21, this.withGlyph = true});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo/neural-calm.png',
      height: fontSize * 1.9,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
