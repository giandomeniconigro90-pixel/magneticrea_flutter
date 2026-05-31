import 'dart:math';
import 'package:flutter/material.dart';
import '../models/build_step.dart';
import '../models/tile_type.dart';
import '../data/tile_types.dart';
import 'tile_painter.dart';

/// Renderer 2D per la guida, sistema a griglia.
///
/// Geometria MAGNA-TILES (tutti i lati = 1 unità):
///   Quadrato grande/piccolo : larghezza=1, altezza=1
///   Triangolo equilatero    : base=1, altezza=√3/2 ≈ 0.866
///   Triangolo isoscele grande: base=1, altezza≈0.866 (stesso)
///   Triangolo isoscele piccolo: base=1, altezza≈0.5
///   Triangolo rettangolo    : cateti 1×1
///   Rombo                   : diagonali 1×0.5 (largh=1, alt=0.5)
///   Esagono                 : larghezza=1, altezza≈0.866
///   Pentagono               : larghezza≈1, altezza≈0.95
///
/// [gx,gy] indica il centro del pezzo in unità logiche.
/// Il bounding box viene calcolato automaticamente e il canvas
/// viene scalato + centrato per riempire lo spazio disponibile.
class GridSchemaPainter extends StatelessWidget {
  final BuildStep step;
  final Animation<double> pulseAnim;

  const GridSchemaPainter({
    super.key,
    required this.step,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final availW = constraints.maxWidth;
      final availH = constraints.maxHeight;

      // Calcola bounding box in unità logiche
      double minGx = double.infinity, maxGx = double.negativeInfinity;
      double minGy = double.infinity, maxGy = double.negativeInfinity;

      for (final p in step.placedPieces) {
        if (!p.usesGrid) continue;
        final hw = _halfW(tileById(p.tileId)?.shape);
        final hh = _halfH(tileById(p.tileId)?.shape);
        minGx = min(minGx, p.gx! - hw);
        maxGx = max(maxGx, p.gx! + hw);
        minGy = min(minGy, p.gy! - hh);
        maxGy = max(maxGy, p.gy! + hh);
      }

      // Fallback se nessun pezzo griglia
      if (minGx == double.infinity) {
        minGx = 0; maxGx = 1; minGy = 0; maxGy = 1;
      }

      const padding = 0.6; // unità di margine attorno
      final bboxW = (maxGx - minGx) + padding * 2;
      final bboxH = (maxGy - minGy) + padding * 2;

      // Calcola quanti pixel vale 1 unità logica
      final unitByW = availW / bboxW;
      final unitByH = availH / bboxH;
      final unit = min(unitByW, unitByH);

      // Offset per centrare il bbox nel canvas
      final totalPxW = bboxW * unit;
      final totalPxH = bboxH * unit;
      final canvasOffX = (availW - totalPxW) / 2;
      final canvasOffY = (availH - totalPxH) / 2;

      // Converte coordinate logiche → pixel
      // L'origine (0,0) in griglia corrisponde a (canvasOffX + padding*unit, canvasOffY + padding*unit)
      double toPixX(double gx) =>
          canvasOffX + (gx - minGx + padding) * unit;
      double toPixY(double gy) =>
          canvasOffY + (gy - minGy + padding) * unit;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDFE6E9)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: step.placedPieces.map((piece) {
              final tile = tileById(piece.tileId);
              if (tile == null) return const SizedBox.shrink();

              final isNew = piece.isNew;
              final color = isNew
                  ? tile.color
                  : tile.color.withOpacity(0.38);

              // Dimensione in pixel del pezzo (larghezza = 1 unità)
              final pw = _pieceW(tile.shape) * unit;
              final ph = _pieceH(tile.shape) * unit;

              // Posizione centro in pixel
              double cx, cy;
              if (piece.usesGrid) {
                cx = toPixX(piece.gx!);
                cy = toPixY(piece.gy!);
              } else {
                // Legacy: posizione relativa
                cx = piece.x * availW;
                cy = piece.y * availH;
              }

              Widget w = CustomPaint(
                size: Size(pw, ph),
                painter: TilePainter(shape: tile.shape, color: color),
              );

              if (piece.rotation != 0) {
                w = Transform.rotate(
                  angle: (piece.rotation * pi) / 180,
                  child: w,
                );
              }

              if (isNew) {
                w = AnimatedBuilder(
                  animation: pulseAnim,
                  builder: (_, child) =>
                      Transform.scale(scale: pulseAnim.value, child: child),
                  child: w,
                );
              }

              return Positioned(
                left: cx - pw / 2,
                top: cy - ph / 2,
                child: w,
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  // ── Dimensioni pezzi in unità logiche ─────────────────────────────────
  // larghezza del pezzo (asse X)
  double _pieceW(TileShape? shape) {
    switch (shape) {
      case TileShape.squareLarge:
      case TileShape.squareSmall:
      case TileShape.squareLargeOpen:
        return 1.0;
      case TileShape.triangleEquilateral:
        return 1.0;
      case TileShape.triangleIsoscaleLarge:
        return 1.0;
      case TileShape.triangleIsoscaleSmall:
        return 1.0;
      case TileShape.triangleRight:
        return 1.0;
      case TileShape.rhombus:
        return 1.0;
      case TileShape.hexagon:
        return 1.0;
      case TileShape.pentagon:
        return 1.0;
      default:
        return 1.0;
    }
  }

  // altezza del pezzo (asse Y)
  double _pieceH(TileShape? shape) {
    switch (shape) {
      case TileShape.squareLarge:
      case TileShape.squareSmall:
      case TileShape.squareLargeOpen:
        return 1.0;
      case TileShape.triangleEquilateral:
        return sqrt(3) / 2; // ≈ 0.866
      case TileShape.triangleIsoscaleLarge:
        return sqrt(3) / 2; // ≈ 0.866
      case TileShape.triangleIsoscaleSmall:
        return 0.5;
      case TileShape.triangleRight:
        return 1.0;
      case TileShape.rhombus:
        return 0.5;
      case TileShape.hexagon:
        return sqrt(3) / 2;
      case TileShape.pentagon:
        return 0.95;
      default:
        return 1.0;
    }
  }

  double _halfW(TileShape? s) => _pieceW(s) / 2;
  double _halfH(TileShape? s) => _pieceH(s) / 2;
}
