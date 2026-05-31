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

      // ── RETTANGOLO ─────────────────────────────────────────────────
      // Rettangolo orizzontale (2:1)
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
        final archTop = h * 0.45;   // dove finisce la parte rettangolare
        final archCx  = w * 0.5;
        final archCy  = archTop;
        final archR   = w * 0.3;
        doorPath
          ..moveTo(w * 0.2, h * 0.92)
          ..lineTo(w * 0.2, archCy)
          ..arcTo(
            Rect.fromCircle(center: Offset(archCx, archCy), radius: archR),
            math.pi,
            -math.pi,
            false,
          )
          ..lineTo(w * 0.8, h * 0.92)
          ..close();
        return doorPath;

      // Finestra: quadrato con griglia interna 2×2 (disegnata come cornice + barre)
      case TileShape.window:
        final winPath = Path();
        // cornice esterna
        winPath.addRect(Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8));
        // barra orizzontale centrale
        winPath.addRect(Rect.fromLTWH(w * 0.1, h * 0.47, w * 0.8, h * 0.06));
        // barra verticale centrale
        winPath.addRect(Rect.fromLTWH(w * 0.47, h * 0.1, w * 0.06, h * 0.8));
        return winPath;

      // ── FUNZIONALI STANDARD ────────────────────────────────────────────
      // Base macchina: rettangolo orizzontale con 4 cerchietti agli angoli (ruote)
      case TileShape.carBase:
        final carPath = Path();
        // scocca
        carPath.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.08, h * 0.25, w * 0.84, h * 0.5),
            const Radius.circular(8),
          ),
        );
        // 4 ruote
        for (final cx in [w * 0.18, w * 0.82]) {
          for (final cy in [h * 0.22, h * 0.78]) {
            carPath.addOval(
              Rect.fromCircle(center: Offset(cx, cy), radius: w * 0.1),
            );
          }
        }
        return carPath;

      // ── CASTLE SPECIAL ───────────────────────────────────────────────

      // Quarto di cerchio: settore circolare a 90°
      case TileShape.quarterCircle:
        return Path()
          ..moveTo(w * 0.05, h * 0.95)
          ..arcTo(
            Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9),
            math.pi / 2,   // parte da sinistra in basso
            -math.pi / 2,  // spazza 90° verso destra in alto
            false,
          )
          ..lineTo(w * 0.05, h * 0.95)
          ..close();

      // Ponte levatoio: rettangolo con arco passante (apertura)
      case TileShape.drawbridge:
        final dbPath = Path();
        // cornice esterna
        dbPath.addRect(Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9));
        // apertura ad arco (asporto visivo — disegnato con fill color)
        final dbInner = Path()
          ..moveTo(w * 0.25, h * 0.92)
          ..lineTo(w * 0.25, h * 0.5)
          ..arcTo(
            Rect.fromCircle(
              center: Offset(w * 0.5, h * 0.5),
              radius: w * 0.25,
            ),
            math.pi,
            -math.pi,
            false,
          )
          ..lineTo(w * 0.75, h * 0.92)
          ..close();
        return Path.combine(PathOperation.difference, dbPath, dbInner);

      // Scala a spirale: cerchio esterno con spirale interna stilizzata
      case TileShape.spiralStaircase:
        final spPath = Path();
        // cerchio esterno (torre)
        spPath.addOval(Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9));
        // spirale stilizzata con 3 cerchi concentrici decrescenti
        spPath.addOval(Rect.fromLTWH(w * 0.2,  h * 0.2,  w * 0.6, h * 0.6));
        spPath.addOval(Rect.fromLTWH(w * 0.35, h * 0.35, w * 0.3, h * 0.3));
        return spPath;

      // Balcone: rettangolo orizzontale con parapetto (linee in cima)
      case TileShape.balcony:
        final balPath = Path();
        // piano del balcone
        balPath.addRect(Rect.fromLTWH(w * 0.05, h * 0.45, w * 0.9, h * 0.4));
        // parapetto superiore
        balPath.addRect(Rect.fromLTWH(w * 0.05, h * 0.3,  w * 0.9, h * 0.1));
        // montanti parapetto
        for (double x = 0.15; x < 0.9; x += 0.15) {
          balPath.addRect(Rect.fromLTWH(w * x, h * 0.3, w * 0.04, h * 0.15));
        }
        return balPath;

      // Finestra castle: pannello con apertura ogivale (sesto acuto)
      case TileShape.windowCastle:
        final wcOuter = Path()
          ..addRect(Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9));
        // apertura ogivale: due archi che si incontrano in punta
        final wcInner = Path();
        final cx = w * 0.5;
        final baseY = h * 0.82;
        final tipY  = h * 0.15;
        final halfW = w * 0.22;
        wcInner
          ..moveTo(cx - halfW, baseY)
          ..arcTo(
            Rect.fromCircle(center: Offset(cx - halfW * 0.35, (baseY + tipY) / 2), radius: halfW * 1.1),
            math.pi * 0.5,
            -math.pi * 0.75,
            false,
          )
          ..lineTo(cx, tipY)
          ..arcTo(
            Rect.fromCircle(center: Offset(cx + halfW * 0.35, (baseY + tipY) / 2), radius: halfW * 1.1),
            math.pi * 1.75,
            -math.pi * 0.75,
            false,
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
