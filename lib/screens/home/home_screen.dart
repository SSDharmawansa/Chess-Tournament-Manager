import 'package:chess_tournament/auth/app_session.dart';
import 'package:chess_tournament/models/tournament.dart';
import 'package:chess_tournament/screens/tournaments/tournament_editor_screen.dart';
import 'package:chess_tournament/screens/tournaments/tournament_list_screen.dart';
import 'package:chess_tournament/state/tournament_controller.dart';
import 'package:chess_tournament/widgets/section_card.dart';
import 'package:chess_tournament/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.session, required this.onExitSession});

  final AppSession session;
  final Future<void> Function() onExitSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tournamentControllerProvider);
    final tournaments = state.tournaments;
    final latest = tournaments.isNotEmpty ? tournaments.first : null;
    final theme = Theme.of(context);
    final workspaceSummary = session.isGuest
        ? 'Create tournaments, manage squads, generate pairings, correct results, and publish standings from one offline workspace.'
        : 'Create tournaments, manage squads, generate pairings, correct results, and publish standings from one Firebase-backed workspace.';
    final recentSubtitle = latest == null
        ? session.isGuest
              ? 'Guest tournaments will appear here after the first local save.'
              : 'Seed data will appear here after the first Firebase sync.'
        : session.isGuest
        ? 'Continue with the most recent tournament saved on this device.'
        : 'Continue with the most recent synced organizer workspace.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Dashboard'),
        actions: [
          IconButton(
            tooltip: session.isGuest ? 'Return to sign in' : 'Sign out',
            onPressed: () => onExitSession(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFF123F39), Color(0xFF1B7F77), Color(0xFFF1E7C9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Chip(
                        avatar: Icon(
                          session.isGuest ? Icons.person_outline_rounded : Icons.cloud_done_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(session.displayName),
                        backgroundColor: Colors.black.withValues(alpha: 0.4),
                        side: BorderSide.none,
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                      Chip(
                        label: Text(session.subtitle),
                        backgroundColor: Colors.black.withValues(alpha: 0.4),
                        side: BorderSide.none,
                        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.86)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Chess Team Tournament Control',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    workspaceSummary,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.86),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (_) => const TournamentEditorScreen())),
                        icon: const Icon(Icons.add),
                        label: const Text('Create tournament'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (_) => const TournamentListScreen())),
                        icon: const Icon(Icons.emoji_events_outlined),
                        label: const Text('Open tournaments'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_off_rounded, color: theme.colorScheme.onErrorContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Tournaments',
                    value: '${tournaments.length}',
                    icon: Icons.emoji_events_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Teams tracked',
                    value: '${tournaments.fold<int>(0, (sum, item) => sum + item.teams.length)}',
                    icon: Icons.groups_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Recent Tournament',
              subtitle: recentSubtitle,
              trailing: TextButton(
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const TournamentListScreen())),
                child: const Text('View all'),
              ),
              child: latest == null
                  ? const Text('No tournaments available.')
                  : _LatestTournamentCard(tournament: latest),
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestTournamentCard extends StatelessWidget {
  const _LatestTournamentCard({required this.tournament});

  final Tournament tournament;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tournament.name, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('${tournament.location} • ${tournament.teams.length} teams'),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const TournamentListScreen())),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Open workspace'),
        ),
      ],
    );
  }
}
