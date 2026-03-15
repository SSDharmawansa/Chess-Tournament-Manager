import 'package:chess_tournament/screens/auth/login_screen.dart';
import 'package:chess_tournament/screens/home/home_screen.dart';
import 'package:chess_tournament/state/auth_controller.dart';
import 'package:chess_tournament/state/firebase_app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGateScreen extends ConsumerWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseApp = ref.watch(firebaseAppProvider);

    return firebaseApp.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Firebase is not configured for this build yet.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
      data: (_) {
        final authState = ref.watch(authControllerProvider);

        if (authState.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authState.isAuthenticated) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
