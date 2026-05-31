import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../data/constructions.dart';
import '../data/tile_types.dart';
import '../models/build_step.dart';
import '../models/tile_type.dart';
import '../widgets/tile_painter.dart';

class GuideScreen extends StatefulWidget {
  final String constructionId;
  const GuideScreen({super.key, required this.constructionId});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen>
    with TickerProviderStateMixin {
  late final construction =
      kConstructions.firstWhere((c) => c.id == widget.constructionId);
  int _currentStep = 0;
  late AnimationController _fadeCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _pulseCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
        lowerBound: 0.85,
        upperBound: 1.0);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _pulseAnim = _pulseCtrl;
    _fadeCtrl.forward();
    _pulseCtrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _goTo(int idx) {
    if (idx < 0 || idx >= construction.steps.length) return;
    _fadeCtrl.reset();
    setState(() => _currentStep = idx);
    _fadeCtrl.forward();
  }

  String? _glbPath(int stepIndex) {
    final isFirst = stepIndex == 0;
    final isLast  = stepIndex == construction.steps.length - 1;
    if (isFirst || isLast) return null;
    if (!construction.is3d) return null;
    return 'assets/models/steps/${construction.id}_step${stepIndex + 1}.glb';
  }

  @override
  Widget build(BuildContext context) {
    final steps    = construction.steps;
    final step     = steps[_currentStep];
    final isLast   = _currentStep == steps.length - 1;
    final isFirst  = _currentStep == 0;
    final tile     = step.tileId != null ? tileById(step.tileId!) : null;
    final progress = (_currentStep + 1) / steps.length;
    final newCount = step.placedPieces.where((p) => p.isNew == true).length;
    final glbPath  = _glbPath(_currentStep);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: Text(construction.name,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE0E0E0),
            color: isLast ? const Color(0xFF20BF6B) : const Color(0xFF4B7BEC),
            minHeight: 6,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: isLast
                  ? _FinaleView()
                  : isFirst
                      ? _IntroView(construction: construction)
                      : _StepView(
                          key: ValueKey('${widget.constructionId}_$_currentStep'),
                          step: step,
                          tile: tile,
                          newCount: newCount,
                          pulseAnim: _pulseAnim,
                          constructionId: widget.constructionId,
                          glbPath: glbPath,
                        ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFDFE6E9)),
                  ),
                  child: Text(
                    '${_currentStep + 1} / ${steps.length}',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: const Color(0xFF636E72)),
                  ),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _goTo(_currentStep - 1),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('\u2190 Indietro',
                          style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isLast
                        ? () => Navigator.pop(context)
                        : () => _goTo(_currentStep + 1),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      backgroundColor: isLast
                          ? const Color(0xFF20BF6B)
                          : const Color(0xFF4B7BEC),
                    ),
                    child: Text(
                      isLast ? '\uD83C\uDF89 Finito!' : 'Avanti \u2192',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepView extends StatelessWidget {
  final BuildStep step;
  final TileType? tile;
  final int newCount;
  final Animation<double> pulseAnim;
  final String constructionId;
  final String? glbPath;

  const _StepView({
    super.key,
    required this.step,
    required this.tile,
    required this.newCount,
    required this.pulseAnim,
    required this.constructionId,
    required this.glbPath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Banner azione ──────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: tile != null
                ? tile!.color.withOpacity(0.10)
                : const Color(0xFFE8EEFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: tile != null
                  ? tile!.color.withOpacity(0.35)
                  : const Color(0xFF4B7BEC).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              if (tile != null)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: tile!.color, shape: BoxShape.circle),
                  child: CustomPaint(
                    painter:
                        TilePainter(shape: tile!.shape, color: Colors.white),
                  ),
                ),
              if (tile != null) const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.action,
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D3436),
                      height: 1.3),
                ),
              ),
              if (tile != null && newCount > 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tile!.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '\u00D7$newCount',
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
        // ── Area visuale ───────────────────────────────────────────────
        Expanded(
          child: glbPath != null
              ? _Viewer3D(glbPath: glbPath!, tileColor: tile?.color)
              : _ProgressSchema(step: step, pulseAnim: pulseAnim),
        ),
      ],
    );
  }
}

// ── Viewer 3D ────────────────────────────────────────────────────────────────
class _Viewer3D extends StatelessWidget {
  final String glbPath;
  final Color? tileColor;

  const _Viewer3D({required this.glbPath, this.tileColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tileColor?.withOpacity(0.35) ?? const Color(0xFFDFE6E9),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (tileColor ?? Colors.blue).withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: ModelViewer(
          src: glbPath,
          autoRotate: false,
          cameraControls: true,
          backgroundColor: Colors.white,
          shadowIntensity: 0.4,
          shadowSoftness: 1.0,
          exposure: 1.2,
          fieldOfView: '25deg',
          cameraOrbit: '45deg 60deg 8m',
          minCameraOrbit: 'auto auto 3m',
          maxCameraOrbit: 'auto auto 20m',
        ),
      ),
    );
  }
}

// ── Schema 2D ─────────────────────────────────────────────────────────────────
// Usa un canvas QUADRATO centrato pari a min(w, h) con padding del 10%.
// Tutti i pezzi vengono scalati e posizionati rispetto a questo quadrato,
// quindi sono sempre visibili indipendentemente dall'aspect ratio dello schermo.
class _ProgressSchema extends StatelessWidget {
  final BuildStep step;
  final Animation<double> pulseAnim;

  const _ProgressSchema({required this.step, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final availW = constraints.maxWidth;
      final availH = constraints.maxHeight;

      // Canvas quadrato centrato
      final side    = min(availW, availH) * 0.92;
      final offsetX = (availW - side) / 2;
      final offsetY = (availH - side) / 2;

      // Dimensione base pezzo: ~16% del lato del canvas
      final baseSize = side * 0.16;

      return Container(
        margin: const EdgeInsets.all(8),
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

              final isNew = piece.isNew == true;

              // Fattore di scala per forma
              final scaleFactor = _shapeScale(tile.shape);
              final size = baseSize * scaleFactor;

              final color = isNew
                  ? tile.color
                  : tile.color.withOpacity(0.38);

              // Posizione: le coordinate (0..1) mappate sul canvas quadrato
              final cx = offsetX + piece.x * side;
              final cy = offsetY + piece.y * side;

              Widget pieceWidget = CustomPaint(
                size: Size(size, size),
                painter: TilePainter(shape: tile.shape, color: color),
              );

              if (piece.rotation != null && piece.rotation != 0) {
                pieceWidget = Transform.rotate(
                  angle: (piece.rotation! * pi) / 180,
                  child: pieceWidget,
                );
              }

              if (isNew) {
                pieceWidget = AnimatedBuilder(
                  animation: pulseAnim,
                  builder: (_, child) => Transform.scale(
                      scale: pulseAnim.value, child: child),
                  child: pieceWidget,
                );
              }

              return Positioned(
                left: cx - size / 2,
                top:  cy - size / 2,
                child: pieceWidget,
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  double _shapeScale(TileShape shape) {
    switch (shape) {
      case TileShape.squareLarge:
        return 1.30;
      case TileShape.hexagon:
        return 1.20;
      case TileShape.triangleIsoscaleLarge:
        return 1.20;
      case TileShape.pentagon:
        return 1.10;
      case TileShape.squareLargeOpen:
        return 1.30;
      case TileShape.squareSmall:
        return 0.85;
      case TileShape.triangleIsoscaleSmall:
        return 0.75;
      case TileShape.rhombus:
        return 1.00;
      case TileShape.triangleEquilateral:
        return 1.00;
      case TileShape.triangleRight:
        return 1.00;
      default:
        return 1.00;
    }
  }
}

// ── Intro ─────────────────────────────────────────────────────────────────────
class _IntroView extends StatelessWidget {
  final dynamic construction;
  const _IntroView({required this.construction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(construction.emoji,
                style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text(
              construction.name,
              style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2D3436)),
            ),
            const SizedBox(height: 12),
            Text(
              construction.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: const Color(0xFF636E72),
                  height: 1.5),
            ),
            const SizedBox(height: 20),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('\uD83D\uDCA1',
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      construction.tip,
                      style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF856404)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Finale ────────────────────────────────────────────────────────────────────
class _FinaleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('\uD83C\uDF89',
              style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          Text('Complimenti!',
              style: GoogleFonts.nunito(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF20BF6B))),
          const SizedBox(height: 8),
          Text(
            'Hai costruito tutto!\nSei stato bravissimo \uD83D\uDC4F',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF636E72),
                height: 1.5),
          ),
        ],
      ),
    );
  }
}
