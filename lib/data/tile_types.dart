import 'package:flutter/material.dart';
import '../models/tile_type.dart';

/// Lista completa di tutte le piastrelle disponibili nell'app.
/// Aggiungere qui ogni nuovo tile mantenendo i commenti di sezione.
const List<TileType> kTileTypes = [

  // ── QUADRATI ──────────────────────────────────────────────────────
  TileType(
    id: 'quadrato_grande',
    label: 'Quadrato Grande',
    short: 'Quadrato Grande',
    color: Color(0xFFFF6B6B),
    bgColor: Color(0xFFFFF0F0),
    shape: TileShape.squareLarge,
    category: TileCategory.structural,
  ),
  TileType(
    id: 'quadrato_piccolo',
    label: 'Quadrato Piccolo',
    short: 'Quadrato Piccolo',
    color: Color(0xFFFF9F43),
    bgColor: Color(0xFFFFF4E6),
    shape: TileShape.squareSmall,
    category: TileCategory.structural,
  ),

  // ── RETTANGOLO ───────────────────────────────────────────────────
  TileType(
    id: 'rettangolo',
    label: 'Rettangolo',
    short: 'Rettangolo Verde',
    color: Color(0xFF26D0CE),
    bgColor: Color(0xFFE5FFFD),
    shape: TileShape.rectangle,
    category: TileCategory.structural,
  ),

  // ── TRIANGOLI ───────────────────────────────────────────────────
  TileType(
    id: 'triangolo_equilatero',
    label: 'Triangolo Equilatero',
    short: 'Triangolo Verde',
    color: Color(0xFF20BF6B),
    bgColor: Color(0xFFE8FFF2),
    shape: TileShape.triangleEquilateral,
    category: TileCategory.structural,
  ),
  TileType(
    id: 'triangolo_isoscele_grande',
    label: 'Triangolo Isoscele Grande',
    short: 'Triangolo Blu',
    color: Color(0xFF45AAF2),
    bgColor: Color(0xFFE3F4FF),
    shape: TileShape.triangleIsoscaleLarge,
    category: TileCategory.structural,
  ),
  TileType(
    id: 'triangolo_isoscele_piccolo',
    label: 'Triangolo Isoscele Piccolo',
    short: 'Triangolo Celeste',
    color: Color(0xFF2BCBBA),
    bgColor: Color(0xFFE5FFFD),
    shape: TileShape.triangleIsoscaleSmall,
    category: TileCategory.structural,
  ),
  TileType(
    id: 'triangolo_rettangolo',
    label: 'Triangolo Rettangolo',
    short: 'Triangolo Viola',
    color: Color(0xFFA55EEA),
    bgColor: Color(0xFFF5E6FF),
    shape: TileShape.triangleRight,
    category: TileCategory.structural,
  ),

  // ── POLIGONI ───────────────────────────────────────────────────
  TileType(
    id: 'rombo',
    label: 'Rombo',
    short: 'Rombo Rosso',
    color: Color(0xFFFC5C65),
    bgColor: Color(0xFFFFE5E7),
    shape: TileShape.rhombus,
    category: TileCategory.structural,
  ),
  TileType(
    id: 'pentagono',
    label: 'Pentagono',
    short: 'Pentagono Arancio',
    color: Color(0xFFFD9644),
    bgColor: Color(0xFFFFF3E5),
    shape: TileShape.pentagon,
    category: TileCategory.structural,
  ),
  TileType(
    id: 'esagono',
    label: 'Esagono Blu',
    short: 'Esagono Blu',
    color: Color(0xFF4B7BEC),
    bgColor: Color(0xFFE8EEFF),
    shape: TileShape.hexagon,
    category: TileCategory.structural,
  ),

  // ── APERTURE (isOpen: true) ────────────────────────────────────
  // Regola: NON usare come base, tetto o parete contenitiva.

  // Quadrato grande con foro quadrato centrale (cornice rossa foto)
  TileType(
    id: 'quadrato_grande_aperto',
    label: 'Quadrato Grande Aperto',
    short: 'Quadrato Aperto',
    color: Color(0xFFFF6B6B),
    bgColor: Color(0xFFFFF0F0),
    shape: TileShape.squareLargeOpen,
    category: TileCategory.opening,
    isOpen: true,
  ),

  // Porta standard con arco semicircolare
  TileType(
    id: 'porta',
    label: 'Porta',
    short: 'Porta Rosa',
    color: Color(0xFFE84393),
    bgColor: Color(0xFFFFE5F3),
    shape: TileShape.door,
    category: TileCategory.opening,
    isOpen: true,
  ),

  // Porta pentagonale: apertura a forma di casetta (foto rossa con punta)
  TileType(
    id: 'porta_pentagono',
    label: 'Porta Pentagono',
    short: 'Porta Casetta',
    color: Color(0xFFFF6B6B),
    bgColor: Color(0xFFFFF0F0),
    shape: TileShape.doorPentagon,
    category: TileCategory.opening,
    isOpen: true,
  ),

  // Finestra griglia 2×2
  TileType(
    id: 'finestra',
    label: 'Finestra',
    short: 'Finestra Rosa',
    color: Color(0xFFE84393),
    bgColor: Color(0xFFFFE5F3),
    shape: TileShape.window,
    category: TileCategory.opening,
    isOpen: true,
  ),

  // ── FUNZIONALI ──────────────────────────────────────────────────
  TileType(
    id: 'base_macchina',
    label: 'Base Macchina',
    short: 'Base con Ruote',
    color: Color(0xFF45AAF2),
    bgColor: Color(0xFFE3F4FF),
    shape: TileShape.carBase,
    category: TileCategory.functional,
  ),

  // ── CASTLE SPECIAL (isCastleSpecial: true) ───────────────────────
  // Questi pezzi sono esclusivi dei set castle MAGNA-TILES.
  // Il bambino deve avere fisicamente il set castle per usarli.
  TileType(
    id: 'quarter_circle_castle',
    label: 'Quarto di Cerchio',
    short: 'Quarto Cerchio',
    color: Color(0xFFD980FA),
    bgColor: Color(0xFFFAE5FF),
    shape: TileShape.quarterCircle,
    category: TileCategory.structural,
    isCastleSpecial: true,
  ),
  TileType(
    id: 'drawbridge',
    label: 'Ponte Levatoio',
    short: 'Drawbridge',
    color: Color(0xFF8B572A),
    bgColor: Color(0xFFF5EDE3),
    shape: TileShape.drawbridge,
    category: TileCategory.opening,
    isCastleSpecial: true,
    isOpen: true,
  ),
  TileType(
    id: 'spiral_staircase',
    label: 'Scala a Spirale',
    short: 'Scala Spirale',
    color: Color(0xFFE8A0BF),
    bgColor: Color(0xFFFFF0F7),
    shape: TileShape.spiralStaircase,
    category: TileCategory.structural,
    isCastleSpecial: true,
  ),
  TileType(
    id: 'balcony',
    label: 'Balcone',
    short: 'Balcone',
    color: Color(0xFFB8860B),
    bgColor: Color(0xFFFFF8E1),
    shape: TileShape.balcony,
    category: TileCategory.structural,
    isCastleSpecial: true,
  ),
  TileType(
    id: 'window_castle',
    label: 'Finestra Castle',
    short: 'Finestra Castle',
    color: Color(0xFF9B59B6),
    bgColor: Color(0xFFF5E6FF),
    shape: TileShape.windowCastle,
    category: TileCategory.opening,
    isCastleSpecial: true,
    isOpen: true,
  ),
];

/// Cerca un tile per id. Ritorna null se non trovato.
TileType? tileById(String id) {
  try {
    return kTileTypes.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
}

/// Ritorna i tile filtrati per categoria d'uso.
List<TileType> tilesByCategory(TileCategory category) =>
    kTileTypes.where((t) => t.category == category).toList();

/// Ritorna solo i tile dei set castle speciali.
List<TileType> get castleSpecialTiles =>
    kTileTypes.where((t) => t.isCastleSpecial).toList();

/// Ritorna solo i tile base (non castle).
List<TileType> get standardTiles =>
    kTileTypes.where((t) => !t.isCastleSpecial).toList();
