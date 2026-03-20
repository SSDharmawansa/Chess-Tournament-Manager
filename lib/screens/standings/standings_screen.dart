import 'package:chess_tournament/state/tournament_controller.dart';
import 'package:chess_tournament/widgets/empty_state.dart';
import 'package:chess_tournament/widgets/standings_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StandingsScreen extends ConsumerWidget {
  const StandingsScreen({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournaments = ref.watch(tournamentControllerProvider).tournaments;
    final match = tournaments.where((item) => item.id == tournamentId).toList();
    final tournament = match.isEmpty ? null : match.first;
    final standings = ref
        .read(tournamentControllerProvider.notifier)
        .standingsFor(tournamentId);

    if (tournament == null) {
      return const Center(child: Text('Tournament not found.'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (standings.isEmpty)
          const EmptyState(
            title: 'Standings unavailable',
            message:
                'Add teams and results to calculate rankings and tie-breaks.',
          )
        else
          StandingsTable(standings: standings),
      ],
    );
  }
}
