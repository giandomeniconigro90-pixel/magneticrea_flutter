import 'package:flutter/material.dart';

class TileType {
  final String id;
  final String label;
  final String short;
  final Color color;
  final Color bgColor;
  final TileShape shape;
  final TileCategory category;
  /// true = la piastrella ha aperture passanti (es. porta, finestra).
  /// Non usare come base, pavimento, tetto o parete contenitiva.
  final bool isOpen;

  const TileType({
    required this.id,
    required this.label,
    required this.short,
    required this.color,
    required this.bgColor,
    required this.shape,
    this.category = TileCategory.standard,
    this.isOpen = false,
  });
}

enum TileShape {
  // ── standard ──────────────────────────────────────────
  squareLarge,
  squareSmall,
  rectangle,
  triangleEquilateral,
  triangleIsoscaleLarge,
  triangleIsoscaleSmall,
  triangleRight,
  rhombus,
  pentagon,
  hexagon,
  door,
  window,
  carBase,
  // ── castle standard ───────────────────────────────────
  quarterCircle,
  glitterSquare,
  glitterTriangle,
  // ── castle special ────────────────────────────────────
  drawbridge,
  spiralStaircase,
  balcony,
  windowCastle,
  // ── micro ─────────────────────────────────────────────
  microSquare,
  microTriangle,
}

enum TileCategory {
  standard,
  castleStandard,
  castleSpecial,
  micro,
}
