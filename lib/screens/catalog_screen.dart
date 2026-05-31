import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../data/constructions.dart';
import '../data/tile_types.dart';
import '../models/construction.dart';
import '../providers/inventory_provider.dart';
import '../providers/favourites_provider.dart';
import '../widgets/tile_painter.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  Difficulty? _filterDiff;
  bool _onlyBuildable = false;

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final invNotifier = ref.read(inventoryProvider.notifier);
    final favs = ref.watch(favouritesProvider);

    final filtered = kConstructions.where((c) {
      if (_filterDiff != null && c.difficulty != _filterDiff) return false;
      if (_onlyBuildable && !invNotifier.canBuild(c.piecesNeeded)) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('🏗️ Catalogo', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filtri
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _FilterChip(label: 'Tutte', selected: _filterDiff == null, onTap: () => setState(() => _filterDiff = null)),
                ...Difficulty.values.map((d) => _FilterChip(
                  label: _diffLabel(d),
                  selected: _filterDiff == d,
                  onTap: () => setState(() => _filterDiff = _filterDiff == d ? null : d),
                  color: _diffColor(d),
                )),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text('✅ Costruibili ora', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 12)),
                  selected: _onlyBuildable,
                  onSelected: (v) => setState(() => _onlyBuildable = v),
                  selectedColor: const Color(0xFF20BF6B).withOpacity(0.2),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final c = filtered[i];
                final buildable = invNotifier.canBuild(c.piecesNeeded);
                final isFav = favs.contains(c.id);
                return _ConstructionCard(
                  construction: c,
                  buildable: buildable,
                  isFav: isFav,
                  onFav: () => ref.read(favouritesProvider.notifier).toggle(c.id),
                  onTap: () => context.push('/construction/${c.id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _diffLabel(Difficulty d) {
    switch (d) {
      case Difficulty.easy: return '⭐ Facile';
      case Difficulty.medium: return '⭐⭐ Medio';
      case Difficulty.hard: return '⭐⭐⭐ Difficile';
      case Difficulty.expert: return '⭐⭐⭐⭐ Esperto';
      case Difficulty.master: return '⭐⭐⭐⭐⭐ Master';
    }
  }

  Color _diffColor(Difficulty d) {
    switch (d) {
      case Difficulty.easy: return const Color(0xFF20BF6B);
      case Difficulty.medium: return const Color(0xFFFD9644);
      case Difficulty.hard: return const Color(0xFFFC5C65);
      case Difficulty.expert: return const Color(0xFFA55EEA);
      case Difficulty.master: return const Color(0xFF2D3436);
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({required this.label, required this.selected, required this.onTap, this.color = const Color(0xFF4B7BEC)});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : const Color(0xFFDFE6E9)),
        ),
        child: Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF636E72))),
      ),
    );
  }
}

class _ConstructionCard extends StatelessWidget {
  final Construction construction;
  final bool buildable;
  final bool isFav;
  final VoidCallback onFav;
  final VoidCallback onTap;

  const _ConstructionCard({required this.construction, required this.buildable, required this.isFav, required this.onFav, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = construction;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isFav ? const Color(0xFFFDC935) : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(c.emoji, style: const TextStyle(fontSize: 36)),
                const Spacer(),
                if (c.is3d)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF4B7BEC), Color(0xFFA55EEA)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('3D', style: GoogleFonts.nunito(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                const SizedBox(width: 6),
                if (!buildable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFFFE5E7), borderRadius: BorderRadius.circular(20)),
                    child: Text('⚠️ Pezzi mancanti', style: GoogleFonts.nunito(color: const Color(0xFFFC5C65), fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onFav,
                  child: Text(isFav ? '⭐' : '☆', style: const TextStyle(fontSize: 22)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(c.name, style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(c.description, style: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFF636E72))),
            const SizedBox(height: 10),
            Row(
              children: [
                _chip(c.difficultyLabel, _diffColor(c.difficulty)),
                const SizedBox(width: 6),
                _chip('⏱ ${c.timeMinutes} min', const Color(0xFF636E72)),
                const SizedBox(width: 6),
                _chip('🧩 ${c.totalPieces} pezzi', const Color(0xFF4B7BEC)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Color _diffColor(Difficulty d) {
    switch (d) {
      case Difficulty.easy: return const Color(0xFF20BF6B);
      case Difficulty.medium: return const Color(0xFFFD9644);
      case Difficulty.hard: return const Color(0xFFFC5C65);
      case Difficulty.expert: return const Color(0xFFA55EEA);
      case Difficulty.master: return const Color(0xFF2D3436);
    }
  }
}
