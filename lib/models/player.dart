import 'package:chess_tournament/models/app_enums.dart';

class Player {
  const Player({
    required this.id,
    required this.name,
    required this.rating,
    required this.boardOrder,
    required this.ageCategory,
    required this.gender,
    required this.federation,
    required this.identificationNumber,
  });

  final String id;
  final String name;
  final int rating;
  final int boardOrder;
  final AgeCategory ageCategory;
  final Gender gender;
  final String federation;
  final String identificationNumber;

  Player copyWith({
    String? id,
    String? name,
    int? rating,
    int? boardOrder,
    AgeCategory? ageCategory,
    Gender? gender,
    String? federation,
    String? identificationNumber,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      boardOrder: boardOrder ?? this.boardOrder,
      ageCategory: ageCategory ?? this.ageCategory,
      gender: gender ?? this.gender,
      federation: federation ?? this.federation,
      identificationNumber: identificationNumber ?? this.identificationNumber,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rating': rating,
        'boardOrder': boardOrder,
        'ageCategory': ageCategory.name,
        'gender': gender.name,
        'federation': federation,
        'identificationNumber': identificationNumber,
      };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      rating: json['rating'] as int,
      boardOrder: json['boardOrder'] as int,
      ageCategory: AgeCategory.values.byName(json['ageCategory'] as String),
      gender: Gender.values.byName(json['gender'] as String),
      federation: json['federation'] as String,
      identificationNumber: json['identificationNumber'] as String? ?? '',
    );
  }
}
