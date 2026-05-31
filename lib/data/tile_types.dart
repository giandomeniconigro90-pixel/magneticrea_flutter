import 'package:flutter/material.dart';
import '../models/tile_type.dart';

const List<TileType> kTileTypes = [
  TileType(
    id: 'quadrato_grande',
    label: 'Quadrato Grande',
    short: 'Quadrato Grande',
    color: Color(0xFFFF6B6B),
    bgColor: Color(0xFFFFF0F0),
    shape: TileShape.squareLarge,
  ),
  TileType(
    id: 'quadrato_piccolo',
    label: 'Quadrato Piccolo',
    short: 'Quadrato Piccolo',
    color: Color(0xFFFF9F43),
    bgColor: Color(0xFFFFF4E6),
    shape: TileShape.squareSmall,
  ),
  TileType(
    id: 'triangolo_equilatero',
    label: 'Triangolo Equilatero',
    short: 'Triangolo Verde',
    color: Color(0xFF20BF6B),
    bgColor: Color(0xFFE8FFF2),
    shape: TileShape.triangleEquilateral,
  ),
  TileType(
    id: 'triangolo_isoscele_grande',
    label: 'Triangolo Isoscele Grande',
    short: 'Triangolo Blu',
    color: Color(0xFF45AAF2),
    bgColor: Color(0xFFE3F4FF),
    shape: TileShape.triangleIsoscaleLarge,
  ),
  TileType(
    id: 'triangolo_isoscele_piccolo',
    label: 'Triangolo Isoscele Piccolo',
    short: 'Triangolo Celeste',
    color: Color(0xFF2BCBBA),
    bgColor: Color(0xFFE5FFFD),
    shape: TileShape.triangleIsoscaleSmall,
  ),
  TileType(
    id: 'triangolo_rettangolo',
    label: 'Triangolo Rettangolo',
    short: 'Triangolo Viola',
    color: Color(0xFFA55EEA),
    bgColor: Color(0xFFF5E6FF),
    shape: TileShape.triangleRight,
  ),
  TileType(
    id: 'rombo',
    label: 'Rombo',
    short: 'Rombo Rosso',
    color: Color(0xFFFC5C65),
    bgColor: Color(0xFFFFE5E7),
    shape: TileShape.rhombus,
  ),
  TileType(
    id: 'pentagono',
    label: 'Pentagono',
    short: 'Pentagono Arancio',
    color: Color(0xFFFD9644),
    bgColor: Color(0xFFFFF3E5),
    shape: TileShape.pentagon,
  ),
  TileType(
    id: 'esagono',
    label: 'Esagono',
    short: 'Esagono Blu',
    color: Color(0xFF4B7BEC),
    bgColor: Color(0xFFE8EEFF),
    shape: TileShape.hexagon,
  ),
];

TileType? tileById(String id) {
  try {
    return kTileTypes.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
}
