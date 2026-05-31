import 'package:flutter/material.dart';

class TileType {
  final String id;
  final String label;
  final String short;
  final Color color;
  final Color bgColor;
  final TileShape shape;

  const TileType({
    required this.id,
    required this.label,
    required this.short,
    required this.color,
    required this.bgColor,
    required this.shape,
  });
}

enum TileShape {
  squareLarge,
  squareSmall,
  triangleEquilateral,
  triangleIsoscaleLarge,
  triangleIsoscaleSmall,
  triangleRight,
  rhombus,
  pentagon,
  hexagon,
}
