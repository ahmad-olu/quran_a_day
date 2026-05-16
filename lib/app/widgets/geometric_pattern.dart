import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:quran_a_day/app/theme.dart';

/// Paints a subtle 8-pointed star Islamic geometric tiling.
/// Pure Flutter — no assets needed.
class GeometricPatternPainter extends CustomPainter {
  GeometricPatternPainter({
    required this.color,
    this.opacity = 0.07,
    this.cellSize = 60,
  });

  final Color color;
  final double opacity;
  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final cols = (size.width / cellSize).ceil() + 1;
    final rows = (size.height / cellSize).ceil() + 1;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final cx = col * cellSize + (row.isOdd ? cellSize / 2 : 0);
        final cy = row * cellSize;
        _drawStar(canvas, paint, Offset(cx, cy), cellSize * 0.38);
      }
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double r) {
    const points = 8;
    final innerR = r * 0.45;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final angle = (math.pi / points) * i - math.pi / 2;
      final radius = i.isEven ? r : innerR;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(GeometricPatternPainter old) =>
      old.color != color || old.opacity != opacity;
}

class GeometricBackground extends StatelessWidget {
  const GeometricBackground({
    super.key,
    required this.child,
    this.cellSize = 60,
    this.opacity = 0.07,
  });

  final Widget child;
  final double cellSize;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: GeometricPatternPainter(
              color: context.colors.primary,
              opacity: opacity,
              cellSize: cellSize,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
