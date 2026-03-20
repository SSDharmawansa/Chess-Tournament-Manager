import 'package:chess_tournament/core/ui_feedback.dart';
import 'package:chess_tournament/models/team.dart';
import 'package:chess_tournament/screens/teams/player_management_screen.dart';
import 'package:chess_tournament/state/tournament_controller.dart';
import 'package:chess_tournament/widgets/empty_state.dart';
import 'package:chess_tournament/widgets/search_filter_bar.dart';
import 'package:chess_tournament/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamManagementScreen extends ConsumerStatefulWidget {
  const TeamManagementScreen({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  ConsumerState<TeamManagementScreen> createState() =>
      _TeamManagementScreenState();
}

class _TeamManagementScreenState extends ConsumerState<TeamManagementScreen> {
  String query = '';
  bool sortBySeed = true;

  @override
  Widget build(BuildContext context) {
    final tournaments = ref.watch(tournamentControllerProvider).tournaments;
    final match = tournaments
        .where((item) => item.id == widget.tournamentId)
        .toList();
    final tournament = match.isEmpty ? null : match.first;

    if (tournament == null) {
      return const Center(child: Text('Tournament not found.'));
    }

    final teams =
        tournament.teams.where((team) {
          final term = query.toLowerCase();
          return team.name.toLowerCase().contains(term) ||
              team.countryOrClub.toLowerCase().contains(term) ||
              team.code.toLowerCase().contains(term);
        }).toList()..sort(
          sortBySeed
              ? (a, b) => b.seedRating.compareTo(a.seedRating)
              : (a, b) => a.name.compareTo(b.name),
        );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SearchFilterBar(
          hintText: 'Search teams, codes, clubs',
          onChanged: (value) => setState(() => query = value),
          trailing: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Seed')),
              ButtonSegment(value: false, label: Text('Name')),
            ],
            selected: {sortBySeed},
            onSelectionChanged: (selection) {
              setState(() => sortBySeed = selection.first);
            },
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Teams',
          subtitle: 'Manage squads, captains, and rosters.',
          trailing: FilledButton.icon(
            onPressed: _showTeamDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add team'),
          ),
          child: teams.isEmpty
              ? const EmptyState(
                  title: 'No teams yet',
                  message:
                      'Add the first team to begin pairings and standings.',
                )
              : Column(
                  children: teams
                      .map(
                        (team) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(team.name),
                            subtitle: Text(
                              '${team.code} • ${team.countryOrClub}\nCaptain: ${team.captainName} • Players: ${team.players.length}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Seed ${team.seedRating}'),
                                TextButton(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PlayerManagementScreen(
                                        tournamentId: widget.tournamentId,
                                        teamId: team.id,
                                      ),
                                    ),
                                  ),
                                  child: const Text('Players'),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }

  Future<void> _showTeamDialog() async {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final clubController = TextEditingController();
    final captainController = TextEditingController();
    final seedController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Team'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Team name'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Team code'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: clubController,
                  decoration: const InputDecoration(
                    labelText: 'Country / club',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: captainController,
                  decoration: const InputDecoration(labelText: 'Captain name'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: seedController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Seed / rating'),
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
              if (!formKey.currentState!.validate()) return;
              final team = Team(
                id: 'team_${DateTime.now().microsecondsSinceEpoch}',
                name: nameController.text.trim(),
                code: codeController.text.trim(),
                countryOrClub: clubController.text.trim(),
                captainName: captainController.text.trim(),
                seedRating: int.tryParse(seedController.text.trim()) ?? 0,
                players: const [],
              );
              try {
                await ref
                    .read(tournamentControllerProvider.notifier)
                    .addTeam(widget.tournamentId, team);
                if (!context.mounted) return;
                Navigator.of(context).pop();
              } catch (error) {
                if (!context.mounted) return;
                showErrorSnackBar(context, 'Could not save team: $error');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
