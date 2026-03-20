import 'package:chess_tournament/models/app_enums.dart';

class BoardResult {
  const BoardResult({
    required this.boardNumber,
    required this.homePlayerId,
    required this.awayPlayerId,
    required this.homeScore,
    required this.awayScore,
  });

  final int boardNumber;
  final String homePlayerId;
  final String awayPlayerId;
  final double homeScore;
  final double awayScore;

  BoardResult copyWith({
    int? boardNumber,
    String? homePlayerId,
    String? awayPlayerId,
    double? homeScore,
    double? awayScore,
  }) {
    return BoardResult(
      boardNumber: boardNumber ?? this.boardNumber,
      homePlayerId: homePlayerId ?? this.homePlayerId,
      awayPlayerId: awayPlayerId ?? this.awayPlayerId,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
    );
  }

  Map<String, dynamic> toJson() => {
    'boardNumber': boardNumber,
    'homePlayerId': homePlayerId,
    'awayPlayerId': awayPlayerId,
    'homeScore': homeScore,
    'awayScore': awayScore,
  };

  factory BoardResult.fromJson(Map<String, dynamic> json) {
    return BoardResult(
      boardNumber: (json['boardNumber'] as num).toInt(),
      homePlayerId: json['homePlayerId'] as String? ?? '',
      awayPlayerId: json['awayPlayerId'] as String? ?? '',
      homeScore: (json['homeScore'] as num).toDouble(),
      awayScore: (json['awayScore'] as num).toDouble(),
    );
  }
}

class RoundMatch {
  const RoundMatch({
    required this.id,
    required this.tableNumber,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.boardResults,
    required this.outcome,
    this.homeTeamScore,
    this.awayTeamScore,
    this.notes = '',
  });

  final String id;
  final int tableNumber;
  final String homeTeamId;
  final String? awayTeamId;
  final List<BoardResult> boardResults;
  final MatchOutcome outcome;
  final double? homeTeamScore;
  final double? awayTeamScore;
  final String notes;

  bool get isCompleted =>
      outcome != MatchOutcome.pending ||
      (homeTeamScore != null && awayTeamScore != null);

  RoundMatch copyWith({
    String? id,
    int? tableNumber,
    String? homeTeamId,
    String? awayTeamId,
    List<BoardResult>? boardResults,
    MatchOutcome? outcome,
    double? homeTeamScore,
    double? awayTeamScore,
    String? notes,
    bool clearAwayTeam = false,
    bool clearScores = false,
  }) {
    return RoundMatch(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: clearAwayTeam ? null : awayTeamId ?? this.awayTeamId,
      boardResults: boardResults ?? this.boardResults,
      outcome: outcome ?? this.outcome,
      homeTeamScore: clearScores ? null : homeTeamScore ?? this.homeTeamScore,
      awayTeamScore: clearScores ? null : awayTeamScore ?? this.awayTeamScore,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tableNumber': tableNumber,
    'homeTeamId': homeTeamId,
    'awayTeamId': awayTeamId,
    'boardResults': boardResults.map((board) => board.toJson()).toList(),
    'outcome': outcome.name,
    'homeTeamScore': homeTeamScore,
    'awayTeamScore': awayTeamScore,
    'notes': notes,
  };

  factory RoundMatch.fromJson(Map<String, dynamic> json) {
    return RoundMatch(
      id: json['id'] as String,
      tableNumber: (json['tableNumber'] as num).toInt(),
      homeTeamId: json['homeTeamId'] as String,
      awayTeamId: json['awayTeamId'] as String?,
      boardResults: (json['boardResults'] as List<dynamic>)
          .map((board) => BoardResult.fromJson(board as Map<String, dynamic>))
          .toList(),
      outcome: MatchOutcome.values.byName(json['outcome'] as String),
      homeTeamScore: (json['homeTeamScore'] as num?)?.toDouble(),
      awayTeamScore: (json['awayTeamScore'] as num?)?.toDouble(),
      notes: json['notes'] as String? ?? '',
    );
  }
}

class TournamentRound {
  const TournamentRound({
    required this.roundNumber,
    required this.matches,
    this.notes = '',
  });

  final int roundNumber;
  final List<RoundMatch> matches;
  final String notes;

  bool get isCompleted => matches.every((match) => match.isCompleted);

  TournamentRound copyWith({
    int? roundNumber,
    List<RoundMatch>? matches,
    String? notes,
  }) {
    return TournamentRound(
      roundNumber: roundNumber ?? this.roundNumber,
      matches: matches ?? this.matches,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'roundNumber': roundNumber,
    'matches': matches.map((match) => match.toJson()).toList(),
    'notes': notes,
  };

  factory TournamentRound.fromJson(Map<String, dynamic> json) {
    return TournamentRound(
      roundNumber: (json['roundNumber'] as num).toInt(),
      matches: (json['matches'] as List<dynamic>)
          .map((match) => RoundMatch.fromJson(match as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String? ?? '',
    );
  }
}
