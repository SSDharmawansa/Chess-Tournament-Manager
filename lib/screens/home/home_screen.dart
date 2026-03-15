import 'package:chess_tournament/models/tournament.dart';
import 'package:chess_tournament/screens/tournaments/tournament_editor_screen.dart';
import 'package:chess_tournament/screens/tournaments/tournament_list_screen.dart';
import 'package:chess_tournament/state/auth_controller.dart';
import 'package:chess_tournament/state/tournament_controller.dart';
import 'package:chess_tournament/widgets/section_card.dart';
import 'package:chess_tournament/widgets/stat_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final state = ref.watch(tournamentControllerProvider);
    final tournaments = state.tournaments;
    final latest = tournaments.isNotEmpty ? tournaments.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Dashboard'),
        actions: [
          if (authState.user != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    ref.read(authControllerProvider.notifier).signOut();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'logout',
                    child: Text('Sign out'),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundImage: authState.user!.photoURL != null
                        ? NetworkImage(authState.user!.photoURL!)
                        : null,
                    child: authState.user!.photoURL == null
                        ? Text(_avatarInitial(authState.user!))
                        : null,
                  ),
                ),
              ),
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
                  Text(
                    'Chess Team Tournament Control',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Create tournaments, manage squads, generate pairings, correct results, and publish standings from one offline workspace.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.86),
                        ),
                  ),
                  if (authState.user != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Signed in as ${authState.user!.displayName ?? authState.user!.email}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TournamentEditorScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Create tournament'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TournamentListScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.emoji_events_outlined),
                        label: const Text('Open tournaments'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
              subtitle: latest == null
                  ? 'Seed data will appear here after startup.'
                  : 'Continue with the most recent organizer workspace.',
              trailing: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TournamentListScreen()),
                ),
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

String _avatarInitial(User user) {
  final source = user.displayName ?? user.email ?? '?';
  return source.isEmpty ? '?' : source.substring(0, 1).toUpperCase();
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
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TournamentListScreen()),
          ),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Open workspace'),
        ),
      ],
    );
  }
}
