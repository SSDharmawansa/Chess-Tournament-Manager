import 'package:chess_tournament/core/theme/app_theme.dart';
import 'package:chess_tournament/firebase_options.dart';
import 'package:chess_tournament/screens/splash_screen.dart';
import 'package:chess_tournament/state/tournament_controller.dart';
import 'package:chess_tournament/storage/firestore_tournament_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(
      ProviderScope(
        overrides: [
          tournamentRepositoryProvider.overrideWithValue(
            FirestoreTournamentRepository(),
          ),
        ],
        child: const ChessTournamentApp(),
      ),
    );
  } catch (error) {
    runApp(ChessTournamentBootstrapErrorApp(error: error));
  }
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

class ChessTournamentBootstrapErrorApp extends StatelessWidget {
  const ChessTournamentBootstrapErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Team Director',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Firebase startup failed',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tournament data now loads from Cloud Firestore. This repo is currently configured for Android, iOS, and macOS. If you changed Firebase apps or deleted FlutterFire config, rerun the setup before launching.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        SelectableText(error.toString()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
