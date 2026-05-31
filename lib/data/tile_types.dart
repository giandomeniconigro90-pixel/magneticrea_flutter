import 'package:flutter/material.dart';
import '../models/tile_type.dart';

const List<TileType> kTileTypes = [

  // ── QUADRATI ──────────────────────────────────────────────────────
  TileType(
    id: 'quadrato_grande',
    label: 'Quadrato Grande',
    short: 'Quadrato Grande',
    color: Color(0xFFFF6B6B),
    bgColor: Color(0xFFFFF0F0),
    shape: TileShape.squareLarge,
    isOpen: false,
  ),
  TileType(
    id: 'quadrato_piccolo',
    label: 'Quadrato Piccolo',
    short: 'Quadrato Piccolo',
    color: Color(0xFFFF9F43),
    bgColor: Color(0xFFFFF4E6),
    shape: TileShape.squareSmall,
    isOpen: false,
  ),

  // ── RETTANGOLO ────────────────────────────────────────────────────
  TileType(
    id: 'rettangolo',
    label: 'Rettangolo',
    short: 'Rettangolo Verde',
    color: Color(0xFF26D0CE),
    bgColor: Color(0xFFE5FFFD),
    shape: TileShape.rectangle,
    isOpen: false,
  ),

  // ── TRIANGOLI ─────────────────────────────────────────────────────
  TileType(
    id: 'triangolo_equilatero',
    label: 'Triangolo Equilatero',
    short: 'Triangolo Verde',
    color: Color(0xFF20BF6B),
    bgColor: Color(0xFFE8FFF2),
    shape: TileShape.triangleEquilateral,
    isOpen: false,
  ),
  TileType(
    id: 'triangolo_isoscele_grande',
    label: 'Triangolo Isoscele Grande',
    short: 'Triangolo Blu',
    color: Color(0xFF45AAF2),
    bgColor: Color(0xFFE3F4FF),
    shape: TileShape.triangleIsoscaleLarge,
    isOpen: false,
  ),
  TileType(
    id: 'triangolo_isoscele_piccolo',
    label: 'Triangolo Isoscele Piccolo',
    short: 'Triangolo Celeste',
    color: Color(0xFF2BCBBA),
    bgColor: Color(0xFFE5FFFD),
    shape: TileShape.triangleIsoscaleSmall,
    isOpen: false,
  ),
  TileType(
    id: 'triangolo_rettangolo',
    label: 'Triangolo Rettangolo',
    short: 'Triangolo Viola',
    color: Color(0xFFA55EEA),
    bgColor: Color(0xFFF5E6FF),
    shape: TileShape.triangleRight,
    isOpen: false,
  ),

  // ── POLIGONI ──────────────────────────────────────────────────────
  TileType(
    id: 'rombo',
    label: 'Rombo',
    short: 'Rombo Rosso',
    color: Color(0xFFFC5C65),
    bgColor: Color(0xFFFFE5E7),
    shape: TileShape.rhombus,
    isOpen: false,
  ),
  TileType(
    id: 'pentagono',
    label: 'Pentagono',
    short: 'Pentagono Arancio',
    color: Color(0xFFFD9644),
    bgColor: Color(0xFFFFF3E5),
    shape: TileShape.pentagon,
    isOpen: false,
  ),
  TileType(
    id: 'esagono',
    label: 'Esagono Blu',
    short: 'Esagono Blu',
    color: Color(0xFF4B7BEC),
    bgColor: Color(0xFFE8EEFF),
    shape: TileShape.hexagon,
    isOpen: false,
  ),

  // ── PIASTRELLE CON APERTURA (isOpen: true) ────────────────────────
  TileType(
    id: 'porta',
    label: 'Porta',
    short: 'Porta Rosa',
    color: Color(0xFFE84393),
    bgColor: Color(0xFFFFE5F3),
    shape: TileShape.door,
    isOpen: true,   // ha arco passante — non usare come base/tetto/parete contenitiva
  ),
  TileType(
    id: 'finestra',
    label: 'Finestra',
    short: 'Finestra Rosa',
    color: Color(0xFFE84393),
    bgColor: Color(0xFFFFE5F3),
    shape: TileShape.window,
    isOpen: true,   // ha griglia passante — non usare come base/tetto/parete contenitiva
  ),

  // ── PEZZI SPECIALI ────────────────────────────────────────────────
  TileType(
    id: 'base_macchina',
    label: 'Base Macchina',
    short: 'Base con Ruote',
    color: Color(0xFF45AAF2),
    bgColor: Color(0xFFE3F4FF),
    shape: TileShape.carBase,
    isOpen: false,  // base solida con ruote
  ),
];

TileType? tileById(String id) {
  try {
    return kTileTypes.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
}
