import 'package:flutter/material.dart';
import '../models/tile_type.dart';

class TilePainter extends CustomPainter {
  final TileShape shape;
  final Color color;

  TilePainter({required this.shape, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeJoin = StrokeJoin.round;

    final path = _buildPath(shape, size);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, stroke);
  }

  Path _buildPath(TileShape shape, Size s) {
    final w = s.width;
    final h = s.height;
    switch (shape) {
      case TileShape.squareLarge:
      case TileShape.squareSmall:
        return Path()..addRect(Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9));

      case TileShape.triangleEquilateral:
        return Path()
          ..moveTo(w * 0.5, h * 0.05)
          ..lineTo(w * 0.95, h * 0.92)
          ..lineTo(w * 0.05, h * 0.92)
          ..close();

      case TileShape.triangleIsoscaleLarge:
        return Path()
          ..moveTo(w * 0.5, h * 0.04)
          ..lineTo(w * 0.96, h * 0.94)
          ..lineTo(w * 0.04, h * 0.94)
          ..close();

      case TileShape.triangleIsoscaleSmall:
        return Path()
          ..moveTo(w * 0.5, h * 0.1)
          ..lineTo(w * 0.9, h * 0.88)
          ..lineTo(w * 0.1, h * 0.88)
          ..close();

      case TileShape.triangleRight:
        return Path()
          ..moveTo(w * 0.05, h * 0.05)
          ..lineTo(w * 0.95, h * 0.95)
          ..lineTo(w * 0.05, h * 0.95)
          ..close();

      case TileShape.rhombus:
        return Path()
          ..moveTo(w * 0.5, h * 0.05)
          ..lineTo(w * 0.95, h * 0.5)
          ..lineTo(w * 0.5, h * 0.95)
          ..lineTo(w * 0.05, h * 0.5)
          ..close();

      case TileShape.pentagon:
        return Path()
          ..moveTo(w * 0.5, h * 0.05)
          ..lineTo(w * 0.95, h * 0.38)
          ..lineTo(w * 0.78, h * 0.95)
          ..lineTo(w * 0.22, h * 0.95)
          ..lineTo(w * 0.05, h * 0.38)
          ..close();

      case TileShape.hexagon:
        return Path()
          ..moveTo(w * 0.5, h * 0.05)
          ..lineTo(w * 0.95, h * 0.27)
          ..lineTo(w * 0.95, h * 0.73)
          ..lineTo(w * 0.5, h * 0.95)
          ..lineTo(w * 0.05, h * 0.73)
          ..lineTo(w * 0.05, h * 0.27)
          ..close();
    }
  }

  @override
  bool shouldRepaint(TilePainter old) => old.shape != shape || old.color != color;
}
