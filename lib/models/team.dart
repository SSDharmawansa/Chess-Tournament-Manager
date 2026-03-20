import 'package:chess_tournament/models/player.dart';

class Team {
  const Team({
    required this.id,
    required this.name,
    required this.code,
    required this.countryOrClub,
    required this.captainName,
    required this.seedRating,
    required this.players,
  });

  final String id;
  final String name;
  final String code;
  final String countryOrClub;
  final String captainName;
  final int seedRating;
  final List<Player> players;

  Team copyWith({
    String? id,
    String? name,
    String? code,
    String? countryOrClub,
    String? captainName,
    int? seedRating,
    List<Player>? players,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      countryOrClub: countryOrClub ?? this.countryOrClub,
      captainName: captainName ?? this.captainName,
      seedRating: seedRating ?? this.seedRating,
      players: players ?? this.players,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'countryOrClub': countryOrClub,
    'captainName': captainName,
    'seedRating': seedRating,
    'players': players.map((player) => player.toJson()).toList(),
  };

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      countryOrClub: json['countryOrClub'] as String,
      captainName: json['captainName'] as String,
      seedRating: (json['seedRating'] as num).toInt(),
      players: (json['players'] as List<dynamic>)
          .map((player) => Player.fromJson(player as Map<String, dynamic>))
          .toList(),
    );
  }
}
