import 'package:chess_tournament/models/app_enums.dart';
import 'package:chess_tournament/models/pairing.dart';
import 'package:chess_tournament/models/team.dart';
import 'package:chess_tournament/state/tournament_controller.dart';
import 'package:chess_tournament/widgets/empty_state.dart';
import 'package:chess_tournament/widgets/round_match_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResultEntryScreen extends ConsumerWidget {
  const ResultEntryScreen({
    super.key,
    required this.tournamentId,
  });

  final String tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournaments = ref.watch(tournamentControllerProvider).tournaments;
    final match = tournaments.where((item) => item.id == tournamentId).toList();
    final tournament = match.isEmpty ? null : match.first;

    if (tournament == null) {
      return const Center(child: Text('Tournament not found.'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (tournament.rounds.isEmpty)
          const EmptyState(
            title: 'No active rounds',
            message: 'Generate pairings first, then enter board-by-board results here.',
          )
        else
          ...tournament.rounds.reversed.map(
            (round) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Round ${round.roundNumber}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...round.matches.map(
                    (match) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RoundMatchTile(
                        match: match,
                        homeTeam: _teamById(tournament.teams, match.homeTeamId)!,
                        awayTeam: match.awayTeamId == null
                            ? null
                            : _teamById(tournament.teams, match.awayTeamId!),
                        onEnterResult: () => _showResultDialog(
                          context,
                          ref,
                          round.roundNumber,
                          match,
                          tournament.teams,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Team? _teamById(List<Team> teams, String id) {
    for (final team in teams) {
      if (team.id == id) return team;
    }
    return null;
  }

  Future<void> _showResultDialog(
    BuildContext context,
    WidgetRef ref,
    int roundNumber,
    RoundMatch match,
    List<Team> teams,
  ) async {
    final homeController =
        TextEditingController(text: match.homeTeamScore?.toString() ?? '');
    final awayController =
        TextEditingController(text: match.awayTeamScore?.toString() ?? '');
    final notesController = TextEditingController(text: match.notes);
    final home = _teamById(teams, match.homeTeamId)!;
    final away = match.awayTeamId == null ? null : _teamById(teams, match.awayTeamId!);
    var outcome = match.outcome == MatchOutcome.pending ? MatchOutcome.draw : match.outcome;
    final boardResults = match.boardResults.isNotEmpty
        ? match.boardResults.map((board) => board.copyWith()).toList()
        : [
            for (var index = 0;
                away != null && index < home.players.length && index < away.players.length;
                index++)
              BoardResult(
                boardNumber: index + 1,
                homePlayerId: home.players[index].id,
                awayPlayerId: away.players[index].id,
                homeScore: 0,
                awayScore: 0,
              ),
          ];

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Round $roundNumber Result'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: homeController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(labelText: home.name),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: awayController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(labelText: away?.name ?? 'Bye'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<MatchOutcome>(
                    initialValue: outcome,
                    decoration: const InputDecoration(labelText: 'Outcome'),
                    items: const [
                      DropdownMenuItem(value: MatchOutcome.homeWin, child: Text('Home win')),
                      DropdownMenuItem(value: MatchOutcome.awayWin, child: Text('Away win')),
                      DropdownMenuItem(value: MatchOutcome.draw, child: Text('Draw')),
                      DropdownMenuItem(value: MatchOutcome.forfeitHome, child: Text('Home forfeits')),
                      DropdownMenuItem(value: MatchOutcome.forfeitAway, child: Text('Away forfeits')),
                      DropdownMenuItem(value: MatchOutcome.bye, child: Text('Bye')),
                    ],
                    onChanged: (value) => setStateDialog(() => outcome = value!),
                  ),
                  const SizedBox(height: 12),
                  if (boardResults.isNotEmpty)
                    ...boardResults.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                SizedBox(width: 54, child: Text('B${entry.value.boardNumber}')),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: entry.value.homeScore.toString(),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(labelText: 'Home'),
                                    onChanged: (value) => boardResults[entry.key] = entry.value
                                        .copyWith(homeScore: double.tryParse(value) ?? 0),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: entry.value.awayScore.toString(),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(labelText: 'Away'),
                                    onChanged: (value) => boardResults[entry.key] = entry.value
                                        .copyWith(awayScore: double.tryParse(value) ?? 0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  TextFormField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await ref.read(tournamentControllerProvider.notifier).updateMatchResult(
                      tournamentId,
                      roundNumber,
                      match.id,
                      homeScore: double.tryParse(homeController.text) ?? 0,
                      awayScore: double.tryParse(awayController.text) ?? 0,
                      outcome: outcome,
                      boardResults: boardResults,
                      notes: notesController.text.trim(),
                    );
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save result'),
            ),
          ],
        ),
      ),
    );
  }
}
