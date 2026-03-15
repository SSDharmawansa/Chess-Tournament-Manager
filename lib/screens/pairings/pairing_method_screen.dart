import 'package:chess_tournament/models/app_enums.dart';
import 'package:chess_tournament/screens/pairings/round_pairings_screen.dart';
import 'package:chess_tournament/state/tournament_controller.dart';
import 'package:chess_tournament/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PairingMethodScreen extends ConsumerWidget {
  const PairingMethodScreen({
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
        SectionCard(
          title: 'Pairing Engine',
          subtitle: 'The pairing logic is isolated from the UI and can be extended later.',
          trailing: FilledButton.icon(
            onPressed: () async {
              await ref
                  .read(tournamentControllerProvider.notifier)
                  .generateNextRound(tournamentId);
            },
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('Generate next round'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(label: Text(tournament.pairingMethod.label)),
              const SizedBox(height: 14),
              Text('Supported structures', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PairingMethod.values
                    .map((method) => Chip(label: Text(method.label)))
                    .toList(),
              ),
              const SizedBox(height: 18),
              Text(
                'Rounds generated: ${tournament.rounds.length}/${tournament.numberOfRounds}',
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RoundPairingsScreen(tournamentId: tournamentId),
                  ),
                ),
                icon: const Icon(Icons.table_rows_rounded),
                label: const Text('Review round pairings'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
