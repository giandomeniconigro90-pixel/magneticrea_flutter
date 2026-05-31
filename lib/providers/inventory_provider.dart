import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/tile_types.dart';

class InventoryNotifier extends StateNotifier<Map<String, int>> {
  InventoryNotifier() : super({}) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, int> loaded = {};
    for (final tile in kTileTypes) {
      loaded[tile.id] = prefs.getInt('inv_${tile.id}') ?? 0;
    }
    state = loaded;
  }

  Future<void> set(String tileId, int qty) async {
    final prefs = await SharedPreferences.getInstance();
    state = {...state, tileId: qty.clamp(0, 9999)};
    await prefs.setInt('inv_$tileId', state[tileId]!);
  }

  Future<void> setQuantity(String tileId, int qty) => set(tileId, qty);

  Future<void> increment(String tileId) async => set(tileId, (state[tileId] ?? 0) + 1);
  Future<void> decrement(String tileId) async => set(tileId, (state[tileId] ?? 0) - 1);

  int get total => state.values.fold(0, (a, b) => a + b);

  bool canBuild(Map<String, int> needed) {
    return needed.entries.every((e) => (state[e.key] ?? 0) >= e.value);
  }
}

final inventoryProvider = StateNotifierProvider<InventoryNotifier, Map<String, int>>(
  (ref) => InventoryNotifier(),
);
