import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      hasCastleSet: prefs.getBool('has_castle_set') ?? false,
    );
  }

  Future<void> setCastleSet(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_castle_set', value);
    state = state.copyWith(hasCastleSet: value);
  }
}

class SettingsState {
  final bool hasCastleSet;
  const SettingsState({this.hasCastleSet = false});
  SettingsState copyWith({bool? hasCastleSet}) =>
      SettingsState(hasCastleSet: hasCastleSet ?? this.hasCastleSet);
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
