import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/tile_type.dart';

/// Disegna il profilo 2D di una piastrella magnetica su un Canvas Flutter.
/// Ogni case dello switch copre esattamente un TileShape —
/// se si aggiunge un nuovo TileShape in tile_type.dart, il compilatore
/// segnalerà subito l'errore qui, impedendo build silenziosi.
class TilePainter extends CustomPainter {
  final TileShape shape;
  final Color color;

  TilePainter({required this.shape, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeJoin = StrokeJoin.round;

    final path = _buildPath(shape, size);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  /// Costruisce il Path 2D per ogni shape.
  /// Le coordinate sono normalizzate su w/h (0.0 – 1.0).
  Path _buildPath(TileShape shape, Size s) {
    final w = s.width;
    final h = s.height;

    switch (shape) {

      // ── QUADRATI ───────────────────────────────────────────────────
      case TileShape.squareLarge:
      case TileShape.squareSmall:
        return Path()
          ..addRect(Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9));

      // Quadrato grande con foro quadrato centrale (cornice rossa)
      // Fedele alla foto: cornice spessa ~18% per lato, foro quadrato centrato
      case TileShape.squareLargeOpen:
        final outer = Path()
          ..addRect(Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9));
        final inner = Path()
          ..addRect(Rect.fromLTWH(w * 0.23, h * 0.23, w * 0.54, h * 0.54));
        return Path.combine(PathOperation.difference, outer, inner);

      // ── RETTANGOLO ─────────────────────────────────────────────────
      case TileShape.rectangle:
        return Path()
          ..addRect(Rect.fromLTWH(w * 0.05, h * 0.15, w * 0.9, h * 0.7));

      // ── TRIANGOLI ──────────────────────────────────────────────────
      case TileShape.triangleEquilateral:
        return Path()
          ..moveTo(w * 0.5,  h * 0.05)
          ..lineTo(w * 0.95, h * 0.92)
          ..lineTo(w * 0.05, h * 0.92)
          ..close();

      case TileShape.triangleIsoscaleLarge:
        return Path()
          ..moveTo(w * 0.5,  h * 0.04)
          ..lineTo(w * 0.96, h * 0.94)
          ..lineTo(w * 0.04, h * 0.94)
          ..close();

      case TileShape.triangleIsoscaleSmall:
        return Path()
          ..moveTo(w * 0.5,  h * 0.1)
          ..lineTo(w * 0.9,  h * 0.88)
          ..lineTo(w * 0.1,  h * 0.88)
          ..close();

      // Triangolo rettangolo: angolo retto in basso a sinistra
      case TileShape.triangleRight:
        return Path()
          ..moveTo(w * 0.05, h * 0.05)
          ..lineTo(w * 0.95, h * 0.95)
          ..lineTo(w * 0.05, h * 0.95)
          ..close();

      // ── POLIGONI ───────────────────────────────────────────────────
      case TileShape.rhombus:
        return Path()
          ..moveTo(w * 0.5,  h * 0.05)
          ..lineTo(w * 0.95, h * 0.5)
          ..lineTo(w * 0.5,  h * 0.95)
          ..lineTo(w * 0.05, h * 0.5)
          ..close();

      case TileShape.pentagon:
        return Path()
          ..moveTo(w * 0.5,  h * 0.05)
          ..lineTo(w * 0.95, h * 0.38)
          ..lineTo(w * 0.78, h * 0.95)
          ..lineTo(w * 0.22, h * 0.95)
          ..lineTo(w * 0.05, h * 0.38)
          ..close();

      case TileShape.hexagon:
        return Path()
          ..moveTo(w * 0.5,  h * 0.05)
          ..lineTo(w * 0.95, h * 0.27)
          ..lineTo(w * 0.95, h * 0.73)
          ..lineTo(w * 0.5,  h * 0.95)
          ..lineTo(w * 0.05, h * 0.73)
          ..lineTo(w * 0.05, h * 0.27)
          ..close();

      // ── APERTURE STANDARD ─────────────────────────────────────────────
      // Porta: rettangolo con semicerchio in cima (arco a tutto sesto)
      case TileShape.door:
        final doorPath = Path();
        final archCy = h * 0.45;
        final archR  = w * 0.3;
        doorPath
          ..moveTo(w * 0.2, h * 0.92)
          ..lineTo(w * 0.2, archCy)
          ..arcTo(
            Rect.fromCircle(center: Offset(w * 0.5, archCy), radius: archR),
            math.pi,
            -math.pi,
            false,
          )
          ..lineTo(w * 0.8, h * 0.92)
          ..close();
        return doorPath;

      // Porta pentagonale (apertura a forma di casa): rettangolo + tetto a punta
      // Fedele alla foto rossa: cornice quadrata, foro interno pentagonale
      case TileShape.doorPentagon:
        final dpOuter = Path()
          ..addRect(Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9));
        // foro interno: rettangolo nella metà inferiore + triangolo in cima
        final dpInner = Path()
          ..moveTo(w * 0.22, h * 0.88)   // basso sinistra
          ..lineTo(w * 0.22, h * 0.48)   // sinistra parete verticale
          ..lineTo(w * 0.50, h * 0.18)   // punta del tetto
          ..lineTo(w * 0.78, h * 0.48)   // destra parete verticale
          ..lineTo(w * 0.78, h * 0.88)   // basso destra
          ..close();
        return Path.combine(PathOperation.difference, dpOuter, dpInner);

      // Finestra: quadrato con griglia interna 2×2 (cornice + barre)
      case TileShape.window:
        final winPath = Path();
        winPath.addRect(Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8));
        winPath.addRect(Rect.fromLTWH(w * 0.1, h * 0.47, w * 0.8, h * 0.06));
        winPath.addRect(Rect.fromLTWH(w * 0.47, h * 0.1, w * 0.06, h * 0.8));
        return winPath;

      // ── FUNZIONALI STANDARD ────────────────────────────────────────────
      // Base macchina: scocca arrotondata + 4 ruote agli angoli
      case TileShape.carBase:
        final carPath = Path();
        carPath.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.08, h * 0.25, w * 0.84, h * 0.5),
            const Radius.circular(8),
          ),
        );
        for (final cx in [w * 0.18, w * 0.82]) {
          for (final cy in [h * 0.22, h * 0.78]) {
            carPath.addOval(
              Rect.fromCircle(center: Offset(cx, cy), radius: w * 0.1),
            );
          }
        }
        return carPath;

      // ── CASTLE SPECIAL ───────────────────────────────────────────────

      // Quarto di cerchio: settore circolare 90°
      case TileShape.quarterCircle:
        return Path()
          ..moveTo(w * 0.05, h * 0.95)
          ..arcTo(
            Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9),
            math.pi / 2,
            -math.pi / 2,
            false,
          )
          ..lineTo(w * 0.05, h * 0.95)
          ..close();

      // Ponte levatoio: cornice con apertura ad arco passante
      case TileShape.drawbridge:
        final dbPath = Path()
          ..addRect(Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9));
        final dbInner = Path()
          ..moveTo(w * 0.25, h * 0.92)
          ..lineTo(w * 0.25, h * 0.5)
          ..arcTo(
            Rect.fromCircle(center: Offset(w * 0.5, h * 0.5), radius: w * 0.25),
            math.pi, -math.pi, false,
          )
          ..lineTo(w * 0.75, h * 0.92)
          ..close();
        return Path.combine(PathOperation.difference, dbPath, dbInner);

      // Scala a spirale: cerchio esterno + cerchi concentrici stilizzati
      case TileShape.spiralStaircase:
        final spPath = Path();
        spPath.addOval(Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9));
        spPath.addOval(Rect.fromLTWH(w * 0.2,  h * 0.2,  w * 0.6, h * 0.6));
        spPath.addOval(Rect.fromLTWH(w * 0.35, h * 0.35, w * 0.3, h * 0.3));
        return spPath;

      // Balcone: piano + parapetto con montanti
      case TileShape.balcony:
        final balPath = Path();
        balPath.addRect(Rect.fromLTWH(w * 0.05, h * 0.45, w * 0.9, h * 0.4));
        balPath.addRect(Rect.fromLTWH(w * 0.05, h * 0.3,  w * 0.9, h * 0.1));
        for (double x = 0.15; x < 0.9; x += 0.15) {
          balPath.addRect(Rect.fromLTWH(w * x, h * 0.3, w * 0.04, h * 0.15));
        }
        return balPath;

      // Finestra castle: pannello con apertura ogivale a sesto acuto
      case TileShape.windowCastle:
        final wcOuter = Path()
          ..addRect(Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9));
        final wcInner = Path();
        final cx     = w * 0.5;
        final baseY  = h * 0.82;
        final tipY   = h * 0.15;
        final halfW  = w * 0.22;
        wcInner
          ..moveTo(cx - halfW, baseY)
          ..arcTo(
            Rect.fromCircle(
              center: Offset(cx - halfW * 0.35, (baseY + tipY) / 2),
              radius: halfW * 1.1,
            ),
            math.pi * 0.5, -math.pi * 0.75, false,
          )
          ..lineTo(cx, tipY)
          ..arcTo(
            Rect.fromCircle(
              center: Offset(cx + halfW * 0.35, (baseY + tipY) / 2),
              radius: halfW * 1.1,
            ),
            math.pi * 1.75, -math.pi * 0.75, false,
          )
          ..lineTo(cx + halfW, baseY)
          ..close();
        return Path.combine(PathOperation.difference, wcOuter, wcInner);
    }
  }

  @override
  bool shouldRepaint(TilePainter old) =>
      old.shape != shape || old.color != color;
}
