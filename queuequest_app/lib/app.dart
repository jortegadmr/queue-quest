import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/qr_scan_screen.dart';
import 'screens/commerce_landing_screen.dart';
import 'screens/ticket_screen.dart';

class QueueQuestApp extends StatelessWidget {
  const QueueQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QueueQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // azul tipo prototipo
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6FB), // fondo gris-azulado suave
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 2,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/scan': (_) => const QrScanScreen(),
        '/commerce': (_) => const CommerceLandingScreen(),
       // '/ticket': (_) => const TicketScreen(),
      },
    );
  }
}
