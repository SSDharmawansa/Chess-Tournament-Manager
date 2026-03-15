import 'package:chess_tournament/models/app_enums.dart';
import 'package:chess_tournament/core/formatters.dart';
import 'package:chess_tournament/models/tournament.dart';
import 'package:chess_tournament/screens/tournaments/tournament_editor_screen.dart';
import 'package:chess_tournament/screens/tournaments/tournament_workspace_screen.dart';
import 'package:chess_tournament/state/tournament_controller.dart';
import 'package:chess_tournament/widgets/empty_state.dart';
import 'package:chess_tournament/widgets/search_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TournamentListScreen extends ConsumerStatefulWidget {
  const TournamentListScreen({super.key});

  @override
  ConsumerState<TournamentListScreen> createState() => _TournamentListScreenState();
}

class _TournamentListScreenState extends ConsumerState<TournamentListScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tournamentControllerProvider);
    final tournaments = state.tournaments.where((tournament) {
      final term = query.toLowerCase();
      return tournament.name.toLowerCase().contains(term) ||
          tournament.location.toLowerCase().contains(term);
    }).toList()
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

    return Scaffold(
      appBar: AppBar(title: const Text('Tournament List')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TournamentEditorScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SearchFilterBar(
              hintText: 'Search tournaments or venues',
              onChanged: (value) => setState(() => query = value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: tournaments.isEmpty
                  ? const EmptyState(
                      title: 'No tournaments found',
                      message: 'Create a new event or clear the search filter.',
                    )
                  : ListView.separated(
                      itemCount: tournaments.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tournament = tournaments[index];
                        return _TournamentTile(tournament: tournament);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TournamentTile extends ConsumerWidget {
  const _TournamentTile({required this.tournament});

  final Tournament tournament;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(tournament.name),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '${tournament.location}\n${AppFormatters.dateRange(tournament.startDate, tournament.endDate)} • ${tournament.pairingMethod.label}',
          ),
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ref.read(tournamentControllerProvider.notifier).setSelectedTournament(
                tournament.id,
              );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TournamentWorkspaceScreen(tournamentId: tournament.id),
            ),
          );
        },
      ),
    );
  }
}
