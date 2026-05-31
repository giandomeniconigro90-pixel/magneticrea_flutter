import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('⚙️ Impostazioni',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Sezione SET ──────────────────────────────────────────
          Text(
            'I miei set MAGNA-TILES',
            style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF636E72),
                letterSpacing: 0.8),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06), blurRadius: 10)
              ],
            ),
            child: SwitchListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              title: Text(
                '🏰 Ho il set Castle',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, fontSize: 15),
              ),
              subtitle: Text(
                settings.hasCastleSet
                    ? 'I pezzi castle sono visibili nell\'inventario'
                    : 'Attiva per sbloccare i pezzi esclusivi castle',
                style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: settings.hasCastleSet
                        ? const Color(0xFF20BF6B)
                        : const Color(0xFF636E72)),
              ),
              value: settings.hasCastleSet,
              activeColor: const Color(0xFF4B7BEC),
              onChanged: (val) => notifier.setCastleSet(val),
            ),
          ),
          const SizedBox(height: 28),

          // ── Info ────────────────────────────────────────────────
          Text(
            'INFO',
            style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF636E72),
                letterSpacing: 0.8),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06), blurRadius: 10)
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Text('🧲', style: TextStyle(fontSize: 28)),
              title: Text('MagnetiCrea',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              subtitle: Text('Versione 1.0',
                  style: GoogleFonts.nunito(
                      fontSize: 12, color: const Color(0xFF636E72))),
            ),
          ),
        ],
      ),
    );
  }
}
