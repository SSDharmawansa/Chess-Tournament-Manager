import 'package:chess_tournament/core/ui_feedback.dart';
import 'package:chess_tournament/models/app_enums.dart';
import 'package:chess_tournament/models/player.dart';
import 'package:chess_tournament/state/tournament_controller.dart';
import 'package:chess_tournament/widgets/empty_state.dart';
import 'package:chess_tournament/widgets/search_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerManagementScreen extends ConsumerStatefulWidget {
  const PlayerManagementScreen({
    super.key,
    required this.tournamentId,
    required this.teamId,
  });

  final String tournamentId;
  final String teamId;

  @override
  ConsumerState<PlayerManagementScreen> createState() =>
      _PlayerManagementScreenState();
}

class _PlayerManagementScreenState
    extends ConsumerState<PlayerManagementScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final tournaments = ref.watch(tournamentControllerProvider).tournaments;
    final tournamentMatches = tournaments
        .where((item) => item.id == widget.tournamentId)
        .toList();
    final tournament = tournamentMatches.isEmpty
        ? null
        : tournamentMatches.first;
    final teamMatches =
        tournament?.teams.where((item) => item.id == widget.teamId).toList() ??
        [];
    final team = teamMatches.isEmpty ? null : teamMatches.first;

    if (team == null) {
      return const Scaffold(body: Center(child: Text('Team not found.')));
    }

    final players = team.players.where((player) {
      final term = query.toLowerCase();
      return player.name.toLowerCase().contains(term) ||
          player.federation.toLowerCase().contains(term);
    }).toList()..sort((a, b) => a.boardOrder.compareTo(b.boardOrder));

    return Scaffold(
      appBar: AppBar(title: Text('${team.name} Players')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPlayerDialog(team.name),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add player'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SearchFilterBar(
              hintText: 'Search players or federation',
              onChanged: (value) => setState(() => query = value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: players.isEmpty
                  ? const EmptyState(
                      title: 'No players yet',
                      message:
                          'Add board members to make team pairings usable.',
                    )
                  : ListView.separated(
                      itemCount: players.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final player = players[index];
                        return Card(
                          child: ListTile(
                            title: Text(player.name),
                            subtitle: Text(
                              'Board ${player.boardOrder} • ${player.rating}\n${player.ageCategory.label} • ${player.gender.label} • ${player.federation}',
                            ),
                            isThreeLine: true,
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

  Future<void> _showPlayerDialog(String teamName) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final ratingController = TextEditingController();
    final boardController = TextEditingController();
    final federationController = TextEditingController();
    final idController = TextEditingController();
    var ageCategory = AgeCategory.open;
    var gender = Gender.open;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Add player to $teamName'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Player name'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: ratingController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Rating',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: boardController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Board'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<AgeCategory>(
                    initialValue: ageCategory,
                    decoration: const InputDecoration(
                      labelText: 'Age category',
                    ),
                    items: AgeCategory.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setStateDialog(() => ageCategory = value!),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<Gender>(
                    initialValue: gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: Gender.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setStateDialog(() => gender = value!),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: federationController,
                    decoration: const InputDecoration(
                      labelText: 'Federation / club',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: idController,
                    decoration: const InputDecoration(labelText: 'ID number'),
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
                final player = Player(
                  id: 'player_${DateTime.now().microsecondsSinceEpoch}',
                  name: nameController.text.trim(),
                  rating: int.tryParse(ratingController.text.trim()) ?? 0,
                  boardOrder: int.tryParse(boardController.text.trim()) ?? 1,
                  ageCategory: ageCategory,
                  gender: gender,
                  federation: federationController.text.trim(),
                  identificationNumber: idController.text.trim(),
                );
                try {
                  await ref
                      .read(tournamentControllerProvider.notifier)
                      .addPlayer(widget.tournamentId, widget.teamId, player);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                } catch (error) {
                  if (!context.mounted) return;
                  showErrorSnackBar(context, 'Could not save player: $error');
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
