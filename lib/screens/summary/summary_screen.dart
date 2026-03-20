import 'package:chess_tournament/models/app_enums.dart';
import 'package:chess_tournament/core/formatters.dart';
import 'package:chess_tournament/services/export_service.dart';
import 'package:chess_tournament/state/tournament_controller.dart';
import 'package:chess_tournament/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournaments = ref.watch(tournamentControllerProvider).tournaments;
    final match = tournaments.where((item) => item.id == tournamentId).toList();
    final tournament = match.isEmpty ? null : match.first;

    if (tournament == null) {
      return const Center(child: Text('Tournament not found.'));
    }

    final exportService = ExportService();
    final summary = exportService.buildSummary(tournament);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SectionCard(
          title: 'Tournament Summary',
          subtitle: 'Snapshot of event setup, rounds, and export readiness.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Venue: ${tournament.location}'),
              Text(
                'Dates: ${AppFormatters.dateRange(tournament.startDate, tournament.endDate)}',
              ),
              Text(
                'Rounds: ${tournament.rounds.length}/${tournament.numberOfRounds}',
              ),
              Text('Teams: ${tournament.teams.length}'),
              Text('Method: ${tournament.pairingMethod.label}'),
              const SizedBox(height: 16),
              Text(summary),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () => _showStub(context, 'PDF export'),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export PDF'),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showStub(context, 'Excel export'),
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Export Excel'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showStub(context, 'Import teams'),
                    icon: const Icon(Icons.file_upload_outlined),
                    label: const Text('Import teams'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showStub(context, 'Cloud sync'),
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Future sync'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showStub(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature is scaffolded in the architecture and ready for implementation.',
        ),
      ),
    );
  }
}
