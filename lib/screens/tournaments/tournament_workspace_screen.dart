import 'package:chess_tournament/screens/pairings/pairing_method_screen.dart';
import 'package:chess_tournament/screens/pairings/round_pairings_screen.dart';
import 'package:chess_tournament/screens/results/result_entry_screen.dart';
import 'package:chess_tournament/screens/standings/standings_screen.dart';
import 'package:chess_tournament/screens/summary/summary_screen.dart';
import 'package:chess_tournament/screens/teams/team_management_screen.dart';
import 'package:chess_tournament/state/tournament_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TournamentWorkspaceScreen extends ConsumerWidget {
  const TournamentWorkspaceScreen({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournaments = ref.watch(tournamentControllerProvider).tournaments;
    final matches = tournaments
        .where((item) => item.id == tournamentId)
        .toList();

    if (matches.isEmpty) {
      return const Scaffold(body: Center(child: Text('Tournament not found.')));
    }

    final selected = matches.first;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(selected.name),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Teams'),
              Tab(text: 'Pairing'),
              Tab(text: 'Rounds'),
              Tab(text: 'Standings'),
              Tab(text: 'Summary'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TeamManagementScreen(tournamentId: tournamentId),
            PairingMethodScreen(tournamentId: tournamentId),
            ResultEntryScreen(tournamentId: tournamentId),
            StandingsScreen(tournamentId: tournamentId),
            SummaryScreen(tournamentId: tournamentId),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RoundPairingsScreen(tournamentId: tournamentId),
            ),
          ),
          icon: const Icon(Icons.view_list_rounded),
          label: const Text('Pairings view'),
        ),
      ),
    );
  }
}
