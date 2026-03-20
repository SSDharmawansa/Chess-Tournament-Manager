import 'package:chess_tournament/models/tournament.dart';
import 'package:chess_tournament/storage/local_storage_service.dart';
import 'package:chess_tournament/storage/tournament_repository.dart';

class LocalTournamentRepository implements TournamentRepository {
  LocalTournamentRepository({required LocalStorageService storageService})
    : _storageService = storageService;

  final LocalStorageService _storageService;

  @override
  Future<List<Tournament>> loadTournaments() =>
      _storageService.loadTournaments();

  @override
  Future<void> saveTournament(Tournament tournament) async {
    final tournaments = await _storageService.loadTournaments();
    final index = tournaments.indexWhere((item) => item.id == tournament.id);

    if (index >= 0) {
      tournaments[index] = tournament;
    } else {
      tournaments.add(tournament);
    }

    await _storageService.saveTournaments(tournaments);
  }

  @override
  Future<void> saveTournaments(List<Tournament> tournaments) {
    return _storageService.saveTournaments(tournaments);
  }
}
