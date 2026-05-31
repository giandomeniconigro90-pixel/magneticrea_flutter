import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesNotifier extends StateNotifier<Set<String>> {
  FavouritesNotifier() : super({}) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('favourites');
    if (raw != null) {
      final list = List<String>.from(jsonDecode(raw));
      state = list.toSet();
    }
  }

  Future<void> toggle(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = {...state};
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = updated;
    await prefs.setString('favourites', jsonEncode(updated.toList()));
  }

  bool isFav(String id) => state.contains(id);
}

final favouritesProvider = StateNotifierProvider<FavouritesNotifier, Set<String>>(
  (ref) => FavouritesNotifier(),
);
