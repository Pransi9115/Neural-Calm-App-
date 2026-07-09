import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/zones.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// The Neural Calm Score ring — matches the backend's donut.
/// The arc fills to score% in the zone colour; the number sits
/// perfectly centred with the CALM SCORE caption beneath.
class ScoreRing extends StatelessWidget {
  final int score;
  final double size;
  const ScoreRing({super.key, required this.score, this.size = 158});

  @override
  Widget build(BuildContext context) {
    final zone = zoneFor(score);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(score: score, color: zone.color),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$score',
                style: cormorant(size: size * 0.30, weight: FontWeight.w700)),
            SizedBox(height: size * 0.015),
            Text('CALM SCORE',
                style: TextStyle(
                  fontSize: size * 0.052,
                  letterSpacing: size * 0.013,
                  fontWeight: FontWeight.w700,
                  color: AppColors.purpleLight,
                )),
          ]),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final int score;
  final Color color;
  _RingPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.105;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.purplePale;
    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawArc(rect, 0, 2 * math.pi, false, track);
    final sweep = 2 * math.pi * (score / 100).clamp(0.0, 1.0);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, progress);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.score != score || old.color != color;
}
