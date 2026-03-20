import 'package:chess_tournament/core/ui_feedback.dart';
import 'package:chess_tournament/models/pairing.dart';
import 'package:chess_tournament/models/team.dart';
import 'package:chess_tournament/state/tournament_controller.dart';
import 'package:chess_tournament/widgets/empty_state.dart';
import 'package:chess_tournament/widgets/round_match_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoundPairingsScreen extends ConsumerStatefulWidget {
  const RoundPairingsScreen({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  ConsumerState<RoundPairingsScreen> createState() =>
      _RoundPairingsScreenState();
}

class _RoundPairingsScreenState extends ConsumerState<RoundPairingsScreen> {
  int? selectedRound;

  @override
  Widget build(BuildContext context) {
    final tournaments = ref.watch(tournamentControllerProvider).tournaments;
    final match = tournaments
        .where((item) => item.id == widget.tournamentId)
        .toList();
    final tournament = match.isEmpty ? null : match.first;

    if (tournament == null) {
      return const Scaffold(body: Center(child: Text('Tournament not found.')));
    }

    final rounds = tournament.rounds;
    final activeRound = selectedRound == null
        ? (rounds.isNotEmpty ? rounds.last : null)
        : () {
            final selected = rounds
                .where((round) => round.roundNumber == selectedRound)
                .toList();
            return selected.isEmpty ? null : selected.first;
          }();

    return Scaffold(
      appBar: AppBar(title: const Text('Round Pairings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              initialValue: activeRound?.roundNumber,
              decoration: const InputDecoration(labelText: 'Round'),
              items: rounds
                  .map(
                    (round) => DropdownMenuItem(
                      value: round.roundNumber,
                      child: Text('Round ${round.roundNumber}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => selectedRound = value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: activeRound == null
                  ? const EmptyState(
                      title: 'No rounds generated',
                      message:
                          'Generate a round from the pairing tab to review pairings here.',
                    )
                  : ListView.separated(
                      itemCount: activeRound.matches.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final match = activeRound.matches[index];
                        return RoundMatchTile(
                          match: match,
                          homeTeam: _teamById(
                            tournament.teams,
                            match.homeTeamId,
                          )!,
                          awayTeam: match.awayTeamId == null
                              ? null
                              : _teamById(tournament.teams, match.awayTeamId!),
                          onEditPairing: () => _editPairingDialog(
                            tournament.teams,
                            activeRound.roundNumber,
                            match,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Team? _teamById(List<Team> teams, String id) {
    for (final team in teams) {
      if (team.id == id) return team;
    }
    return null;
  }

  Future<void> _editPairingDialog(
    List<Team> teams,
    int roundNumber,
    RoundMatch match,
  ) async {
    var homeId = match.homeTeamId;
    String? awayId = match.awayTeamId;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Edit Table ${match.tableNumber}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: homeId,
                decoration: const InputDecoration(labelText: 'Home team'),
                items: teams
                    .map(
                      (team) => DropdownMenuItem(
                        value: team.id,
                        child: Text(team.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setStateDialog(() => homeId = value!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: awayId,
                decoration: const InputDecoration(labelText: 'Away team'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Bye'),
                  ),
                  ...teams
                      .where((team) => team.id != homeId)
                      .map(
                        (team) => DropdownMenuItem<String?>(
                          value: team.id,
                          child: Text(team.name),
                        ),
                      ),
                ],
                onChanged: (value) => setStateDialog(() => awayId = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await ref
                      .read(tournamentControllerProvider.notifier)
                      .updatePairing(
                        widget.tournamentId,
                        roundNumber,
                        match.id,
                        homeTeamId: homeId,
                        awayTeamId: awayId,
                      );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                } catch (error) {
                  if (!context.mounted) return;
                  showErrorSnackBar(
                    context,
                    'Could not update pairing: $error',
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
