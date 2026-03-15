import 'package:chess_tournament/models/app_enums.dart';
import 'package:chess_tournament/models/pairing.dart';
import 'package:chess_tournament/models/team.dart';

class Tournament {
  const Tournament({
    required this.id,
    required this.name,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.numberOfRounds,
    required this.timeControl,
    required this.type,
    required this.notes,
    required this.pairingMethod,
    required this.teams,
    required this.rounds,
    required this.lastUpdated,
  });

  final String id;
  final String name;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfRounds;
  final String timeControl;
  final TournamentType type;
  final String notes;
  final PairingMethod pairingMethod;
  final List<Team> teams;
  final List<TournamentRound> rounds;
  final DateTime lastUpdated;

  Tournament copyWith({
    String? id,
    String? name,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int? numberOfRounds,
    String? timeControl,
    TournamentType? type,
    String? notes,
    PairingMethod? pairingMethod,
    List<Team>? teams,
    List<TournamentRound>? rounds,
    DateTime? lastUpdated,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      numberOfRounds: numberOfRounds ?? this.numberOfRounds,
      timeControl: timeControl ?? this.timeControl,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      pairingMethod: pairingMethod ?? this.pairingMethod,
      teams: teams ?? this.teams,
      rounds: rounds ?? this.rounds,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'numberOfRounds': numberOfRounds,
        'timeControl': timeControl,
        'type': type.name,
        'notes': notes,
        'pairingMethod': pairingMethod.name,
        'teams': teams.map((team) => team.toJson()).toList(),
        'rounds': rounds.map((round) => round.toJson()).toList(),
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      numberOfRounds: json['numberOfRounds'] as int,
      timeControl: json['timeControl'] as String,
      type: TournamentType.values.byName(json['type'] as String),
      notes: json['notes'] as String,
      pairingMethod: PairingMethod.values.byName(json['pairingMethod'] as String),
      teams: (json['teams'] as List<dynamic>)
          .map((team) => Team.fromJson(team as Map<String, dynamic>))
          .toList(),
      rounds: (json['rounds'] as List<dynamic>)
          .map((round) => TournamentRound.fromJson(round as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}
