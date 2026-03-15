import 'package:chess_tournament/state/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF102F2D), Color(0xFF16645D), Color(0xFFF2E8CD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Organizer Sign In',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sign in with Google to manage chess team tournaments, pairings, results, and standings.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.security_rounded),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Place google-services.json and GoogleService-Info.plist in the project before testing Firebase sign-in.',
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (authState.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            authState.errorMessage!,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: authState.isLoading
                                ? null
                                : authController.supportsAuthenticate
                                    ? authController.signIn
                                    : null,
                            icon: const Icon(Icons.login_rounded),
                            label: Text(
                              authState.isLoading
                                  ? 'Signing in...'
                                  : 'Continue with Google',
                            ),
                          ),
                        ),
                        if (!authController.supportsAuthenticate) ...[
                          const SizedBox(height: 12),
                          Text(
                            'This platform does not currently expose Google authentication through this package. Use Android or iOS for the mobile login flow.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
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
