import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../data/constructions.dart';
import '../data/tile_types.dart';
import '../providers/inventory_provider.dart';
import '../providers/favourites_provider.dart';
import '../widgets/tile_painter.dart';

class ConstructionDetailScreen extends ConsumerWidget {
  final String constructionId;
  const ConstructionDetailScreen({super.key, required this.constructionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final construction = kConstructions.firstWhere((c) => c.id == constructionId);
    final inventory = ref.watch(inventoryProvider);
    final invNotifier = ref.read(inventoryProvider.notifier);
    final favs = ref.watch(favouritesProvider);
    final isFav = favs.contains(construction.id);
    final buildable = invNotifier.canBuild(construction.piecesNeeded);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4B7BEC), Color(0xFFA55EEA)],
                  ),
                ),
                child: Center(
                  child: Text(construction.emoji, style: const TextStyle(fontSize: 80)),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Text(isFav ? '⭐' : '☆', style: const TextStyle(fontSize: 24)),
                onPressed: () => ref.read(favouritesProvider.notifier).toggle(construction.id),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(construction.name, style: GoogleFonts.nunito(fontSize: 26, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(construction.description, style: GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF636E72))),
                  const SizedBox(height: 16),
                  // Pezzi necessari
                  Text('Pezzi necessari', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFB2BEC3), letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: construction.piecesNeeded.entries.map((e) {
                      final tile = tileById(e.key);
                      if (tile == null) return const SizedBox();
                      final avail = inventory[e.key] ?? 0;
                      final ok = avail >= e.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: ok ? tile.bgColor : const Color(0xFFFFE5E7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ok ? tile.color : const Color(0xFFFC5C65)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 22, height: 22, child: CustomPaint(painter: TilePainter(shape: tile.shape, color: tile.color))),
                            const SizedBox(width: 6),
                            Text(tile.label, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: ok ? const Color(0xFF2D3436) : const Color(0xFFFC5C65))),
                            Text('  ×${e.value}', style: GoogleFonts.nunito(fontSize: 11, color: ok ? const Color(0xFF636E72) : const Color(0xFFFC5C65))),
                            Text(ok ? ' ✓' : ' ✗', style: TextStyle(fontSize: 12, color: ok ? tile.color : const Color(0xFFFC5C65))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  if (construction.tip.isNotEmpty) ...[  
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBE6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFD43B)),
                      ),
                      child: Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(child: Text(construction.tip, style: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFF555555)))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Bottone avvia guida
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        backgroundColor: buildable ? const Color(0xFF4B7BEC) : const Color(0xFFB2BEC3),
                      ),
                      onPressed: () => context.push('/guide/${construction.id}'),
                      child: Text(
                        buildable ? '▶️  Inizia la guida passo-passo' : '⚠️  Pezzi mancanti — vedi comunque la guida',
                        style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
