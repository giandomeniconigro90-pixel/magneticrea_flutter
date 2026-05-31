import 'package:flutter/material.dart';

class TileType {
  final String id;
  final String label;
  final String short;
  final Color color;
  final Color bgColor;
  final TileShape shape;
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
    this.isOpen = false,
  });
}

enum TileShape {
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
}
