import 'package:chess_tournament/models/app_enums.dart';
import 'package:chess_tournament/models/pairing.dart';
import 'package:chess_tournament/models/standing.dart';
import 'package:chess_tournament/models/team.dart';
import 'package:chess_tournament/models/tournament.dart';

class StandingsService {
  List<TeamStanding> build(Tournament tournament) {
    final stats = <String, _StandingAccumulator>{};
    for (final team in tournament.teams) {
      stats[team.id] = _StandingAccumulator(team: team);
    }

    for (final round in tournament.rounds) {
      for (final match in round.matches.where((match) => match.isCompleted)) {
        _applyMatch(stats, match);
      }
    }

    final provisional = stats.values.toList();
    for (final entry in provisional) {
      entry.buchholz = _opponentScoreTotal(tournament, entry.team.id, stats);
      entry.sonnebornBerger = _sonnebornBerger(tournament, entry.team.id, stats);
    }

    provisional.sort((a, b) {
      final byMatch = b.matchPoints.compareTo(a.matchPoints);
      if (byMatch != 0) return byMatch;
      final byGame = b.gamePoints.compareTo(a.gamePoints);
      if (byGame != 0) return byGame;
      final byBuchholz = b.buchholz.compareTo(a.buchholz);
      if (byBuchholz != 0) return byBuchholz;
      return b.team.seedRating.compareTo(a.team.seedRating);
    });

    return [
      for (var index = 0; index < provisional.length; index++)
        TeamStanding(
          rank: index + 1,
          teamId: provisional[index].team.id,
          teamName: provisional[index].team.name,
          seedRating: provisional[index].team.seedRating,
          matchesPlayed: provisional[index].matchesPlayed,
          matchPoints: provisional[index].matchPoints,
          gamePoints: provisional[index].gamePoints,
          buchholz: provisional[index].buchholz,
          sonnebornBerger: provisional[index].sonnebornBerger,
          wins: provisional[index].wins,
          draws: provisional[index].draws,
          losses: provisional[index].losses,
        ),
    ];
  }

  void _applyMatch(Map<String, _StandingAccumulator> stats, RoundMatch match) {
    final home = stats[match.homeTeamId];
    if (home == null) return;

    if (match.awayTeamId == null) {
      home.matchesPlayed += 1;
      home.wins += 1;
      home.matchPoints += 2;
      home.gamePoints += match.homeTeamScore ?? 0;
      return;
    }

    final away = stats[match.awayTeamId];
    if (away == null) return;

    home.matchesPlayed += 1;
    away.matchesPlayed += 1;
    home.gamePoints += match.homeTeamScore ?? 0;
    away.gamePoints += match.awayTeamScore ?? 0;

    switch (match.outcome) {
      case MatchOutcome.homeWin:
      case MatchOutcome.forfeitAway:
        home.wins += 1;
        away.losses += 1;
        home.matchPoints += 2;
        break;
      case MatchOutcome.awayWin:
      case MatchOutcome.forfeitHome:
        away.wins += 1;
        home.losses += 1;
        away.matchPoints += 2;
        break;
      case MatchOutcome.draw:
        home.draws += 1;
        away.draws += 1;
        home.matchPoints += 1;
        away.matchPoints += 1;
        break;
      case MatchOutcome.bye:
        home.wins += 1;
        home.matchPoints += 2;
        break;
      case MatchOutcome.pending:
        break;
    }
  }

  double _opponentScoreTotal(
    Tournament tournament,
    String teamId,
    Map<String, _StandingAccumulator> stats,
  ) {
    var total = 0.0;
    for (final round in tournament.rounds) {
      for (final match in round.matches.where((match) => match.isCompleted)) {
        if (match.homeTeamId == teamId && match.awayTeamId != null) {
          total += stats[match.awayTeamId]!.matchPoints;
        } else if (match.awayTeamId == teamId) {
          total += stats[match.homeTeamId]!.matchPoints;
        }
      }
    }
    return total;
  }

  double _sonnebornBerger(
    Tournament tournament,
    String teamId,
    Map<String, _StandingAccumulator> stats,
  ) {
    var total = 0.0;
    for (final round in tournament.rounds) {
      for (final match in round.matches.where((match) => match.isCompleted)) {
        if (match.awayTeamId == null) continue;
        final isHome = match.homeTeamId == teamId;
        final isAway = match.awayTeamId == teamId;
        if (!isHome && !isAway) continue;

        final opponentId = isHome ? match.awayTeamId! : match.homeTeamId;
        final opponentPoints = stats[opponentId]!.matchPoints;
        final homeScore = match.homeTeamScore ?? 0;
        final awayScore = match.awayTeamScore ?? 0;

        if ((isHome && homeScore > awayScore) || (isAway && awayScore > homeScore)) {
          total += opponentPoints;
        } else if (homeScore == awayScore) {
          total += opponentPoints / 2;
        }
      }
    }
    return total;
  }
}

class _StandingAccumulator {
  _StandingAccumulator({required this.team});

  final Team team;
  int matchesPlayed = 0;
  int wins = 0;
  int draws = 0;
  int losses = 0;
  double matchPoints = 0;
  double gamePoints = 0;
  double buchholz = 0;
  double sonnebornBerger = 0;
}
