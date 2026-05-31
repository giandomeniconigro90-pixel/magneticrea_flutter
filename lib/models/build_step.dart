/// Un singolo passo della guida di costruzione.
/// [tileId] è null se il passo non coinvolge un pezzo specifico (es. intro/finale).
/// [placedTileIds] è la lista di tutti i pezzi già posizionati fino a questo passo
/// (usata per disegnare lo schema progressivo animato).
class BuildStep {
  final int stepNumber;
  final String? tileId;       // pezzo da aggiungere in questo passo
  final String action;        // testo breve per il bambino
  final List<PlacedPiece> placedPieces; // posizioni di tutti i pezzi già messi

  const BuildStep({
    required this.stepNumber,
    this.tileId,
    required this.action,
    this.placedPieces = const [],
  });
}

/// Pezzo già posizionato nello schema progressivo.
class PlacedPiece {
  final String tileId;
  final double x;       // posizione relativa 0.0–1.0 nel canvas
  final double y;
  final double rotation; // gradi
  final double scale;
  final bool isNew;     // true = pezzo aggiunto in questo passo (evidenziato)

  const PlacedPiece({
    required this.tileId,
    required this.x,
    required this.y,
    this.rotation = 0,
    this.scale = 1.0,
    this.isNew = false,
  });
}
