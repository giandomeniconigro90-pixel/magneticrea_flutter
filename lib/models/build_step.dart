/// Un singolo passo della guida di costruzione.
class BuildStep {
  final int stepNumber;
  final String? tileId;
  final String action;
  final List<PlacedPiece> placedPieces;

  const BuildStep({
    required this.stepNumber,
    this.tileId,
    required this.action,
    this.placedPieces = const [],
  });
}

/// Pezzo posizionato nello schema.
///
/// Sistema GRIGLIA (preferito):
///   [gx], [gy] = coordinate in "unità logiche" dove 1 unità = lato quadrato grande.
///   Il renderer calcola automaticamente pixel/unità e centra il bounding box.
///   Usare questo sistema per costruzioni nuove o corrette.
///
/// Sistema LEGACY (0.0–1.0):
///   [x], [y] = posizione relativa nel canvas (0=sinistra/alto, 1=destra/basso).
///   Mantenuto per retrocompatibilità.
class PlacedPiece {
  final String tileId;

  // ── Sistema griglia ──────────────────────────────────────────
  final double? gx; // colonna in unità logiche (null = usa legacy x/y)
  final double? gy; // riga in unità logiche

  // ── Sistema legacy ───────────────────────────────────────────
  final double x;
  final double y;

  final double rotation; // gradi
  final double scale;
  final bool isNew;

  const PlacedPiece({
    required this.tileId,
    this.gx,
    this.gy,
    this.x = 0.5,
    this.y = 0.5,
    this.rotation = 0,
    this.scale = 1.0,
    this.isNew = false,
  });

  bool get usesGrid => gx != null && gy != null;
}
