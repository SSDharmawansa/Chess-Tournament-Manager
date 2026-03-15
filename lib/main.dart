import 'package:chess_tournament/core/theme/app_theme.dart';
import 'package:chess_tournament/screens/splash_screen.dart';
import 'package:chess_tournament/state/tournament_controller.dart';
import 'package:chess_tournament/storage/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = LocalStorageService();
  await storage.init();

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(storage),
      ],
      child: const ChessTournamentApp(),
    ),
  );
}

class ChessTournamentApp extends StatelessWidget {
  const ChessTournamentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Team Director',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const SplashScreen(),
    );
  }
}
