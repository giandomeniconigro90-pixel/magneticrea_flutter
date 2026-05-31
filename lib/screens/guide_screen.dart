import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final tile = step.tileId != null ? tileById(step.tileId!) : null;
    final progress = (_currentStep + 1) / steps.length;

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
          // Schema progressivo animato
          Expanded(
            flex: 5,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _SchemaCanvas(step: step),
            ),
          ),
          // Card azione
          Expanded(
            flex: 4,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _ActionCard(step: step, tile: tile, stepNum: _currentStep + 1, total: steps.length, isLast: isLast),
            ),
          ),
          // Bottoni navigazione
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _goTo(_currentStep - 1),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('← Indietro', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
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
                      isLast ? '🎉 Finito!' : 'Avanti →',
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

class _SchemaCanvas extends StatelessWidget {
  final BuildStep step;
  const _SchemaCanvas({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
      ),
      child: step.placedPieces.isEmpty
          ? Center(child: Text('👋', style: const TextStyle(fontSize: 60)))
          : LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: step.placedPieces.map((p) {
                    final tile = tileById(p.tileId);
                    if (tile == null) return const SizedBox();
                    final size = 50.0 * p.scale;
                    return Positioned(
                      left: p.x * constraints.maxWidth - size / 2,
                      top: p.y * constraints.maxHeight - size / 2,
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Transform.rotate(
                          angle: p.rotation * 3.14159 / 180,
                          child: Container(
                            width: size, height: size,
                            decoration: p.isNew
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [BoxShadow(color: tile.color.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)],
                                )
                              : null,
                            child: CustomPaint(painter: TilePainter(shape: tile.shape, color: p.isNew ? tile.color : tile.color.withOpacity(0.45))),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final BuildStep step;
  final dynamic tile;
  final int stepNum;
  final int total;
  final bool isLast;

  const _ActionCard({required this.step, required this.tile, required this.stepNum, required this.total, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLast ? const Color(0xFFF0FFF6) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isLast ? const Color(0xFF20BF6B) : const Color(0xFF4B7BEC), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
      ),
      child: Row(
        children: [
          // Numero passo
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: isLast ? const Color(0xFF20BF6B) : const Color(0xFF4B7BEC),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                isLast ? '✓' : '$stepNum',
                style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Icona pezzo
          if (tile != null) ...[  
            SizedBox(
              width: 48, height: 48,
              child: CustomPaint(painter: TilePainter(shape: tile.shape, color: tile.color)),
            ),
            const SizedBox(width: 14),
          ],
          // Testo azione
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  step.action,
                  style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF2D3436), height: 1.35),
                ),
                if (tile != null) ...[  
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: tile.bgColor, borderRadius: BorderRadius.circular(20)),
                    child: Text(tile.short, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: tile.color)),
                  ),
                ],
                const SizedBox(height: 4),
                Text('Passo $stepNum di $total', style: GoogleFonts.nunito(fontSize: 11, color: const Color(0xFFB2BEC3))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
