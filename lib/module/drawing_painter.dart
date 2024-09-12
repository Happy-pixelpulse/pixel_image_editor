

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final double strokeWidth;
  final Color brushColor;

  DrawingPainter(this.points, this.strokeWidth, this.brushColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = brushColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
