import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/tile_types.dart';
import '../providers/inventory_provider.dart';
import '../widgets/tile_painter.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    final notifier = ref.read(inventoryProvider.notifier);
    final total = notifier.total;

    return Scaffold(
      appBar: AppBar(
        title: Text('📦 Inventario', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4B7BEC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Totale: $total', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: kTileTypes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final tile = kTileTypes[i];
          final qty = inventory[tile.id] ?? 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: qty > 0 ? tile.color.withOpacity(0.6) : Colors.transparent, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40, height: 40,
                  child: CustomPaint(painter: TilePainter(shape: tile.shape, color: tile.color)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tile.label, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14)),
                      if (qty > 0)
                        Text('$qty pezzi', style: GoogleFonts.nunito(color: tile.color, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _CircleBtn(
                      icon: Icons.remove,
                      enabled: qty > 0,
                      color: const Color(0xFFDFE6E9),
                      onTap: () => notifier.decrement(tile.id),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$qty',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 18, fontWeight: FontWeight.w900,
                          color: qty > 0 ? tile.color : const Color(0xFFB2BEC3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _CircleBtn(
                      icon: Icons.add,
                      enabled: true,
                      color: tile.color,
                      onTap: () => notifier.increment(tile.id),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.enabled, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: enabled ? color : const Color(0xFFF0F0F0),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: enabled ? Colors.white : const Color(0xFFB2BEC3)),
      ),
    );
  }
}
