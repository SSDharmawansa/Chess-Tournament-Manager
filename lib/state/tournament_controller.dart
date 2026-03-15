import 'package:chess_tournament/dummy_data/dummy_tournaments.dart';
import 'package:chess_tournament/models/app_enums.dart';
import 'package:chess_tournament/models/pairing.dart';
import 'package:chess_tournament/models/player.dart';
import 'package:chess_tournament/models/standing.dart';
import 'package:chess_tournament/models/team.dart';
import 'package:chess_tournament/models/tournament.dart';
import 'package:chess_tournament/pairing_engines/pairing_engine.dart';
import 'package:chess_tournament/services/standings_service.dart';
import 'package:chess_tournament/storage/local_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('Storage must be overridden at startup.');
});

final standingsServiceProvider = Provider((ref) => StandingsService());

final tournamentControllerProvider =
    StateNotifierProvider<TournamentController, TournamentState>((ref) {
  final controller = TournamentController(
    storage: ref.watch(localStorageServiceProvider),
    standingsService: ref.watch(standingsServiceProvider),
  );
  controller.load();
  return controller;
});

class TournamentState {
  const TournamentState({
    this.isLoading = true,
    this.tournaments = const [],
    this.selectedTournamentId,
  });

  final bool isLoading;
  final List<Tournament> tournaments;
  final String? selectedTournamentId;

  TournamentState copyWith({
    bool? isLoading,
    List<Tournament>? tournaments,
    String? selectedTournamentId,
  }) {
    return TournamentState(
      isLoading: isLoading ?? this.isLoading,
      tournaments: tournaments ?? this.tournaments,
      selectedTournamentId: selectedTournamentId ?? this.selectedTournamentId,
    );
  }
}

class TournamentController extends StateNotifier<TournamentState> {
  TournamentController({
    required LocalStorageService storage,
    required StandingsService standingsService,
  })  : _storage = storage,
        _standingsService = standingsService,
        super(const TournamentState());

  final LocalStorageService _storage;
  final StandingsService _standingsService;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final stored = await _storage.loadTournaments();
    final tournaments = stored.isEmpty ? DummyTournaments.seed() : stored;
    if (stored.isEmpty) {
      await _storage.saveTournaments(tournaments);
    }
    state = state.copyWith(
      isLoading: false,
      tournaments: tournaments,
      selectedTournamentId: tournaments.isNotEmpty ? tournaments.first.id : null,
    );
  }

  Tournament? byId(String tournamentId) {
    for (final tournament in state.tournaments) {
      if (tournament.id == tournamentId) return tournament;
    }
    return null;
  }

  Future<void> saveTournament(Tournament tournament) async {
    final next = [...state.tournaments];
    final index = next.indexWhere((item) => item.id == tournament.id);
    final updated = tournament.copyWith(lastUpdated: DateTime.now());

    if (index >= 0) {
      next[index] = updated;
    } else {
      next.add(updated);
    }

    await _commit(next, updated.id);
  }

  Future<void> setSelectedTournament(String tournamentId) async {
    state = state.copyWith(selectedTournamentId: tournamentId);
  }

  Future<void> addTeam(String tournamentId, Team team) async {
    final tournament = byId(tournamentId);
    if (tournament == null) return;
    final updated = tournament.copyWith(teams: [...tournament.teams, team]);
    await saveTournament(updated);
  }

  Future<void> addPlayer(String tournamentId, String teamId, Player player) async {
    final tournament = byId(tournamentId);
    if (tournament == null) return;
    final nextTeams = tournament.teams.map((team) {
      if (team.id != teamId) return team;
      final nextPlayers = [...team.players, player]
        ..sort((a, b) => a.boardOrder.compareTo(b.boardOrder));
      return team.copyWith(players: nextPlayers);
    }).toList();
    await saveTournament(tournament.copyWith(teams: nextTeams));
  }

  Future<void> generateNextRound(String tournamentId) async {
    final tournament = byId(tournamentId);
    if (tournament == null) return;
    if (tournament.rounds.length >= tournament.numberOfRounds) return;

    final engine = PairingEngineFactory.create(tournament.pairingMethod);
    final standings = _standingsService.build(tournament);
    final proposal = engine.generate(
      PairingRequest(
        tournament: tournament,
        teams: tournament.teams,
        standings: standings,
        roundNumber: tournament.rounds.length + 1,
      ),
    );

    final round = TournamentRound(
      roundNumber: proposal.roundNumber,
      matches: proposal.matches,
      notes: proposal.notes,
    );
    await saveTournament(tournament.copyWith(rounds: [...tournament.rounds, round]));
  }

  Future<void> updatePairing(
    String tournamentId,
    int roundNumber,
    String matchId, {
    required String homeTeamId,
    String? awayTeamId,
  }) async {
    final tournament = byId(tournamentId);
    if (tournament == null) return;

    final nextRounds = tournament.rounds.map((round) {
      if (round.roundNumber != roundNumber) return round;
      final nextMatches = round.matches.map((match) {
        if (match.id != matchId) return match;
        return match.copyWith(
          homeTeamId: homeTeamId,
          awayTeamId: awayTeamId,
          clearAwayTeam: awayTeamId == null,
        );
      }).toList();
      return round.copyWith(matches: nextMatches);
    }).toList();

    await saveTournament(tournament.copyWith(rounds: nextRounds));
  }

  Future<void> updateMatchResult(
    String tournamentId,
    int roundNumber,
    String matchId, {
    required double homeScore,
    required double awayScore,
    required MatchOutcome outcome,
    required List<BoardResult> boardResults,
    String notes = '',
  }) async {
    final tournament = byId(tournamentId);
    if (tournament == null) return;

    final nextRounds = tournament.rounds.map((round) {
      if (round.roundNumber != roundNumber) return round;
      final nextMatches = round.matches.map((match) {
        if (match.id != matchId) return match;
        return match.copyWith(
          homeTeamScore: homeScore,
          awayTeamScore: awayScore,
          outcome: outcome,
          boardResults: boardResults,
          notes: notes,
        );
      }).toList();
      return round.copyWith(matches: nextMatches);
    }).toList();

    await saveTournament(tournament.copyWith(rounds: nextRounds));
  }

  List<TeamStanding> standingsFor(String tournamentId) {
    final tournament = byId(tournamentId);
    if (tournament == null) return [];
    return _standingsService.build(tournament);
  }

  Future<void> _commit(List<Tournament> tournaments, String selectedTournamentId) async {
    await _storage.saveTournaments(tournaments);
    state = state.copyWith(
      tournaments: tournaments,
      isLoading: false,
      selectedTournamentId: selectedTournamentId,
    );
  }
}
