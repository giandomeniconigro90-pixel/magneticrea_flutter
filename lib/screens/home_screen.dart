import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/inventory_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(inventoryProvider.notifier).total;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4B7BEC), Color(0xFFA55EEA)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header con tasto impostazioni ──────────────────
                Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined,
                          color: Colors.white70),
                      tooltip: 'Impostazioni',
                      onPressed: () => context.push('/settings'),
                    ),
                  ],
                ),
                Text('🧲', style: GoogleFonts.nunito(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  'MagnetiCrea',
                  style: GoogleFonts.nunito(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Costruisci mondi con le tue piastrelle magnetiche!',
                  style:
                      GoogleFonts.nunito(fontSize: 15, color: Colors.white70),
                ),
                const SizedBox(height: 40),
                _MenuCard(
                  icon: '📦',
                  title: 'Il mio inventario',
                  subtitle: total > 0
                      ? '$total piastrelle caricate'
                      : 'Inserisci le tue piastrelle',
                  color: const Color(0xFF20BF6B),
                  onTap: () => context.push('/inventory'),
                ),
                const SizedBox(height: 14),
                _MenuCard(
                  icon: '🏗️',
                  title: 'Catalogo costruzioni',
                  subtitle: 'Sfoglia tutte le idee, da facile a Master',
                  color: const Color(0xFFFF9F43),
                  onTap: () => context.push('/catalog'),
                ),
                const Spacer(),
                Center(
                  child: Text(
                    'MagnetiCrea v1.0',
                    style:
                        GoogleFonts.nunito(color: Colors.white38, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.nunito(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2D3436))),
                  Text(subtitle,
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: const Color(0xFF636E72))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
