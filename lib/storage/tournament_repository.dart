import 'package:chess_tournament/models/tournament.dart';

abstract class TournamentRepository {
  Future<List<Tournament>> loadTournaments();

  Future<void> saveTournament(Tournament tournament);

  Future<void> saveTournaments(List<Tournament> tournaments);
}
