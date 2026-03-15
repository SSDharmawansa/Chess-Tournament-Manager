import 'dart:convert';

import 'package:chess_tournament/models/tournament.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const _boxName = 'chess_tournament_box';
  static const _tournamentsKey = 'tournaments';
  late Box<String> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<List<Tournament>> loadTournaments() async {
    final payload = _box.get(_tournamentsKey);
    if (payload == null || payload.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(payload) as List<dynamic>;
    return decoded
        .map((item) => Tournament.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTournaments(List<Tournament> tournaments) {
    final payload =
        jsonEncode(tournaments.map((tournament) => tournament.toJson()).toList());
    return _box.put(_tournamentsKey, payload);
  }
}
