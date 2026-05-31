import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'router.dart';

void main() {
  runApp(const ProviderScope(child: MagnetiCreaApp()));
}

class MagnetiCreaApp extends StatelessWidget {
  const MagnetiCreaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MagnetiCrea',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4B7BEC),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF0F4FF),
      ),
      routerConfig: appRouter,
    );
  }
}
