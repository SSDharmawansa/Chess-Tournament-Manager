import 'package:chess_tournament/models/app_enums.dart';
import 'package:chess_tournament/models/pairing.dart';
import 'package:chess_tournament/models/team.dart';
import 'package:chess_tournament/pairing_engines/pairing_engine.dart';

class RoundRobinPairingEngine implements PairingEngine {
  @override
  PairingProposal generate(PairingRequest request) {
    final rounds = _buildSchedule(request.teams, request.tournament.pairingMethod);
    final roundIndex = request.roundNumber - 1;
    final selected = roundIndex < rounds.length ? rounds[roundIndex] : <RoundMatch>[];

    return PairingProposal(
      roundNumber: request.roundNumber,
      matches: selected,
      notes: 'Round-robin pairing generated using the circle method.',
    );
  }

  List<List<RoundMatch>> _buildSchedule(List<Team> source, PairingMethod method) {
    final teams = [...source];
    if (teams.length.isOdd) {
      teams.add(
        const Team(
          id: '__bye__',
          name: 'Bye',
          code: 'BYE',
          countryOrClub: '',
          captainName: '',
          seedRating: 0,
          players: [],
        ),
      );
    }

    final schedule = <List<RoundMatch>>[];
    final rotation = [...teams];
    final baseRounds = rotation.length - 1;
    final totalRounds =
        method == PairingMethod.doubleRoundRobin ? baseRounds * 2 : baseRounds;

    for (var round = 0; round < totalRounds; round++) {
      final current = <RoundMatch>[];
      for (var index = 0; index < rotation.length / 2; index++) {
        final teamA = rotation[index];
        final teamB = rotation[rotation.length - 1 - index];
        if (teamA.id == '__bye__' || teamB.id == '__bye__') continue;
        final reverse = round >= baseRounds;
        final home = reverse ? teamB : teamA;
        final away = reverse ? teamA : teamB;
        current.add(
          RoundMatch(
            id: 'rr_${round + 1}_$index',
            tableNumber: index + 1,
            homeTeamId: home.id,
            awayTeamId: away.id,
            boardResults: _emptyBoards(home, away),
            outcome: MatchOutcome.pending,
          ),
        );
      }
      schedule.add(current);
      rotation.insert(1, rotation.removeLast());
    }

    return schedule;
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
}
