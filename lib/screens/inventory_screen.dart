import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/tile_types.dart';
import '../providers/inventory_provider.dart';
import '../widgets/tile_painter.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String id, int qty) {
    if (!_controllers.containsKey(id)) {
      _controllers[id] = TextEditingController(text: '$qty');
    }
    return _controllers[id]!;
  }

  @override
  Widget build(BuildContext context) {
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
          final controller = _controllerFor(tile.id, qty);

          // Aggiorna il controller solo se il valore esterno cambia
          // (evita loop durante la digitazione)
          if (controller.text != '$qty' && !controller.selection.isValid) {
            controller.text = '$qty';
          }

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
                      onTap: () {
                        notifier.decrement(tile.id);
                        controller.text = '${(qty - 1).clamp(0, 9999)}';
                      },
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 52,
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: qty > 0 ? tile.color : const Color(0xFFB2BEC3),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: tile.color.withOpacity(0.4)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: tile.color, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                          ),
                        ),
                        onChanged: (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null && parsed >= 0) {
                            notifier.setQuantity(tile.id, parsed);
                          }
                        },
                        onTap: () => controller.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: controller.text.length,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _CircleBtn(
                      icon: Icons.add,
                      enabled: true,
                      color: tile.color,
                      onTap: () {
                        notifier.increment(tile.id);
                        controller.text = '${qty + 1}';
                      },
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
