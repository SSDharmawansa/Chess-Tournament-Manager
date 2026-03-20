import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
    required this.onGoogleSignIn,
    required this.onContinueAsGuest,
    required this.isGoogleSignInAvailable,
    this.isBusy = false,
    this.activityLabel,
    this.statusMessage,
  });

  final Future<void> Function() onGoogleSignIn;
  final Future<void> Function() onContinueAsGuest;
  final bool isGoogleSignInAvailable;
  final bool isBusy;
  final String? activityLabel;
  final String? statusMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B3D3A), Color(0xFF0F766E), Color(0xFFEFE8D5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Icon(
                          Icons.groups_2_rounded,
                          size: 62,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Chess Team Director',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in with Google to use the Firebase workspace, or continue as a guest to keep tournaments on this device.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: isBusy || !isGoogleSignInAvailable
                              ? null
                              : () => onGoogleSignIn(),
                          icon: const Icon(Icons.login_rounded),
                          label: const Text('Sign in with Google'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isBusy ? null : () => onContinueAsGuest(),
                          icon: const Icon(Icons.person_outline_rounded),
                          label: const Text('Continue as guest'),
                        ),
                      ),
                      if (!isGoogleSignInAvailable) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Google authentication is currently unavailable on this device or build, but guest mode is ready.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (activityLabel != null) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                activityLabel!,
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (statusMessage != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
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
    );
  }
}
