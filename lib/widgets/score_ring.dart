import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// The circular Neural Calm Score gauge.
class ScoreRing extends StatelessWidget {
  final double score;
  final double size;

  const ScoreRing({super.key, required this.score, this.size = 190});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(score: score),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${score.round()}',
                  style: fraunces(
                      size: size * 0.26, color: AppColors.primaryDeep)),
              Text('of 100',
                  style: TextStyle(
                      fontSize: size * 0.07, color: AppColors.inkMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double score;

  _RingPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.085;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.lavenderSoft;

    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.primary;

    canvas.drawArc(rect, 0, 2 * math.pi, false, track);
    final sweep = 2 * math.pi * (score / 100.0).clamp(0.0, 1.0);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, progress);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.score != score;
}
