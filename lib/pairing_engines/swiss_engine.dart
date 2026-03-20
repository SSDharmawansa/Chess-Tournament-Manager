import 'package:chess_tournament/models/app_enums.dart';
import 'package:chess_tournament/models/pairing.dart';
import 'package:chess_tournament/models/team.dart';
import 'package:chess_tournament/pairing_engines/pairing_engine.dart';

class SwissPairingEngine implements PairingEngine {
  @override
  PairingProposal generate(PairingRequest request) {
    final teams = _orderedTeams(request);
    final previousPairs = <String>{};
    for (final round in request.tournament.rounds) {
      for (final match in round.matches) {
        if (match.awayTeamId != null) {
          previousPairs.add(_pairKey(match.homeTeamId, match.awayTeamId!));
        }
      }
    }

    final matches = <RoundMatch>[];
    final queue = [...teams];
    var table = 1;

    while (queue.length > 1) {
      final home = queue.removeAt(0);
      var opponentIndex = 0;
      for (var index = 0; index < queue.length; index++) {
        if (!previousPairs.contains(_pairKey(home.id, queue[index].id))) {
          opponentIndex = index;
          break;
        }
      }

      final away = queue.removeAt(opponentIndex);
      matches.add(
        RoundMatch(
          id: 'round_${request.roundNumber}_table_$table',
          tableNumber: table,
          homeTeamId: home.id,
          awayTeamId: away.id,
          boardResults: _emptyBoards(home, away),
          outcome: MatchOutcome.pending,
        ),
      );
      table++;
    }

    if (queue.isNotEmpty) {
      final byeTeam = queue.removeLast();
      matches.add(
        RoundMatch(
          id: 'round_${request.roundNumber}_bye',
          tableNumber: table,
          homeTeamId: byeTeam.id,
          awayTeamId: null,
          boardResults: const [],
          outcome: MatchOutcome.bye,
          homeTeamScore: 1,
          awayTeamScore: 0,
          notes: 'Automatic bye',
        ),
      );
    }

    return PairingProposal(
      roundNumber: request.roundNumber,
      matches: matches,
      notes: 'Swiss-style pairing ordered by current standings and seed.',
    );
  }

  List<Team> _orderedTeams(PairingRequest request) {
    if (request.roundNumber == 1 || request.standings.isEmpty) {
      final teams = [...request.teams];
      teams.sort((a, b) => b.seedRating.compareTo(a.seedRating));
      return teams;
    }

    return request.standings
        .map(
          (standing) =>
              request.teams.firstWhere((team) => team.id == standing.teamId),
        )
        .toList();
  }

  List<BoardResult> _emptyBoards(Team home, Team away) {
    final count = home.players.length < away.players.length
        ? home.players.length
        : away.players.length;
    return [
      for (var index = 0; index < count; index++)
        BoardResult(
          boardNumber: index + 1,
          homePlayerId: home.players[index].id,
          awayPlayerId: away.players[index].id,
          homeScore: 0,
          awayScore: 0,
        ),
    ];
  }

  String _pairKey(String a, String b) {
    final values = [a, b]..sort();
    return values.join('_');
  }
}
