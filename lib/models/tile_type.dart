import 'package:flutter/material.dart';

/// Modello che rappresenta una singola piastrella magnetica.
class TileType {
  final String id;
  final String label;
  final String short;
  final Color color;
  final Color bgColor;
  final TileShape shape;

  /// Categoria d'uso nella costruzione:
  /// structural  → regge o definisce la struttura
  /// functional  → serve a far muovere qualcosa o creare percorso
  /// opening     → ha aperture passanti (porta, finestra, drawbridge)
  final TileCategory category;

  /// true = questa piastrella appartiene ai set castle speciali.
  /// Il bambino deve avere il set castle fisicamente per usarla.
  final bool isCastleSpecial;

  /// true = la piastrella ha aperture passanti (arco, griglia, foro).
  /// NON usare come base, pavimento, tetto o parete contenitiva.
  final bool isOpen;

  const TileType({
    required this.id,
    required this.label,
    required this.short,
    required this.color,
    required this.bgColor,
    required this.shape,
    required this.category,
    this.isCastleSpecial = false,
    this.isOpen = false,
  });
}

/// Categoria d'uso della piastrella nella costruzione.
enum TileCategory {
  /// Regge o definisce la struttura (muri, tetti, basi solide).
  structural,

  /// Serve a far muovere qualcosa o creare un percorso (base macchina,
  /// ponte levatoio come passaggio funzionale).
  functional,

  /// Ha aperture passanti — non usare come base/tetto/parete contenitiva.
  opening,
}

/// Forma geometrica della piastrella.
enum TileShape {
  // ── forme base standard ──────────────────────────────────────────
  squareLarge,            // quadrato grande pieno
  squareSmall,            // quadrato piccolo pieno
  rectangle,              // rettangolo pieno
  triangleEquilateral,    // triangolo equilatero
  triangleIsoscaleLarge,  // triangolo isoscele grande
  triangleIsoscaleSmall,  // triangolo isoscele piccolo
  triangleRight,          // triangolo rettangolo
  rhombus,                // rombo
  pentagon,               // pentagono
  hexagon,                // esagono

  // ── aperture standard ────────────────────────────────────────────
  squareLargeOpen,        // quadrato grande con foro quadrato centrale (cornice)
  door,                   // porta (arco semicircolare passante)
  doorPentagon,           // porta a forma di casa (apertura pentagonale passante)
  window,                 // finestra griglia 2×2 passante

  // ── funzionali standard ──────────────────────────────────────────
  carBase,                // base macchina con ruote

  // ── forme castle (isCastleSpecial: true) ─────────────────────────
  quarterCircle,          // quarto di cerchio — arco/torre
  drawbridge,             // ponte levatoio — apertura passante
  spiralStaircase,        // scala a spirale
  balcony,                // balcone — sporgenza architettonica
  windowCastle,           // finestra castle — ridisegnata per castelli
}
