import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../data/constructions.dart';
import '../data/tile_types.dart';
import '../models/build_step.dart';
import '../widgets/tile_painter.dart';

class GuideScreen extends StatefulWidget {
  final String constructionId;
  const GuideScreen({super.key, required this.constructionId});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> with SingleTickerProviderStateMixin {
  late final construction = kConstructions.firstWhere((c) => c.id == widget.constructionId);
  int _currentStep = 0;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _goTo(int idx) {
    if (idx < 0 || idx >= construction.steps.length) return;
    _animCtrl.reset();
    setState(() => _currentStep = idx);
    _animCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final steps = construction.steps;
    final step = steps[_currentStep];
    final isLast = _currentStep == steps.length - 1;
    final isFirst = _currentStep == 0;
    final tile = step.tileId != null ? tileById(step.tileId!) : null;
    final progress = (_currentStep + 1) / steps.length;
    final newCount = step.placedPieces.where((p) => p.isNew && p.tileId == step.tileId).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: Text(construction.name, style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
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
                      : tile != null
                          ? _Viewer3D(
                              key: ValueKey('${widget.constructionId}_${_currentStep}_${tile.id}'),
                              tileId: tile.id,
                              color: tile.color,
                              count: newCount > 0 ? newCount : 1,
                              label: tile.label,
                              action: step.action,
                            )
                          : _IntroView(construction: construction),
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
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14, color: const Color(0xFF636E72)),
                  ),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _goTo(_currentStep - 1),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('\u2190 Indietro', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isLast ? () => Navigator.pop(context) : () => _goTo(_currentStep + 1),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: isLast ? const Color(0xFF20BF6B) : const Color(0xFF4B7BEC),
                    ),
                    child: Text(
                      isLast ? '\uD83C\uDF89 Finito!' : 'Avanti \u2192',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 16),
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

class _Viewer3D extends StatelessWidget {
  final String tileId;
  final Color color;
  final int count;
  final String label;
  final String action;

  const _Viewer3D({
    super.key,
    required this.tileId,
    required this.color,
    required this.count,
    required this.label,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.35), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Text('\uD83D\uDC40', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  action,
                  style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF2D3436), height: 1.4),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              ModelViewer(
                src: 'assets/models/$tileId.glb',
                autoRotate: true,
                autoRotateDelay: 0,
                rotationPerSecond: '30deg',
                cameraControls: true,
                backgroundColor: const Color(0xFFF0F4FF),
                shadowIntensity: 1,
              ),
              Positioned(
                top: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Text(
                    count == 1 ? '\u00D7 1 pezzo' : '\u00D7 $count pezzi',
                    style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ),
              Positioned(
                bottom: 12, left: 0, right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: color),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
            Text(construction.emoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text(
              construction.name,
              style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: const Color(0xFF2D3436)),
            ),
            const SizedBox(height: 12),
            Text(
              construction.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 15, color: const Color(0xFF636E72), height: 1.5),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('\uD83D\uDCA1', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      construction.tip,
                      style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF856404)),
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

class _FinaleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('\uD83C\uDF89', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          Text('Complimenti!',
            style: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF20BF6B))),
          const SizedBox(height: 8),
          Text('Hai costruito tutto!\nSei stato bravissimo \uD83D\uDC4F',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF636E72), height: 1.5)),
        ],
      ),
    );
  }
}
