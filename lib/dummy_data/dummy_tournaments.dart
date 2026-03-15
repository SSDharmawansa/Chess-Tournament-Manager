import 'package:chess_tournament/models/app_enums.dart';
import 'package:chess_tournament/models/pairing.dart';
import 'package:chess_tournament/models/player.dart';
import 'package:chess_tournament/models/team.dart';
import 'package:chess_tournament/models/tournament.dart';

class DummyTournaments {
  static List<Tournament> seed() {
    final teams = [
      Team(
        id: 'team_a',
        name: 'Royal Knights',
        code: 'RK',
        countryOrClub: 'Colombo Chess Club',
        captainName: 'Ishara Perera',
        seedRating: 2225,
        players: const [
          Player(id: 'a1', name: 'Nalin De Silva', rating: 2301, boardOrder: 1, ageCategory: AgeCategory.open, gender: Gender.male, federation: 'SLCF', identificationNumber: 'SLC-001'),
          Player(id: 'a2', name: 'Madhavi Fernando', rating: 2180, boardOrder: 2, ageCategory: AgeCategory.open, gender: Gender.female, federation: 'SLCF', identificationNumber: 'SLC-002'),
          Player(id: 'a3', name: 'Rivin Jayasena', rating: 2115, boardOrder: 3, ageCategory: AgeCategory.under18, gender: Gender.male, federation: 'SLCF', identificationNumber: 'SLC-003'),
          Player(id: 'a4', name: 'Kavya Edirisinghe', rating: 2084, boardOrder: 4, ageCategory: AgeCategory.under16, gender: Gender.female, federation: 'SLCF', identificationNumber: 'SLC-004'),
        ],
      ),
      Team(
        id: 'team_b',
        name: 'Metro Bishops',
        code: 'MB',
        countryOrClub: 'Metropolitan Academy',
        captainName: 'Dhanuka Silva',
        seedRating: 2144,
        players: const [
          Player(id: 'b1', name: 'Samith Wimal', rating: 2210, boardOrder: 1, ageCategory: AgeCategory.open, gender: Gender.male, federation: 'SLCF', identificationNumber: 'MBA-001'),
          Player(id: 'b2', name: 'Ariya Raj', rating: 2162, boardOrder: 2, ageCategory: AgeCategory.open, gender: Gender.other, federation: 'SLCF', identificationNumber: 'MBA-002'),
          Player(id: 'b3', name: 'Chathuni Amarasekara', rating: 2040, boardOrder: 3, ageCategory: AgeCategory.under18, gender: Gender.female, federation: 'SLCF', identificationNumber: 'MBA-003'),
          Player(id: 'b4', name: 'Nevin Niroshan', rating: 1989, boardOrder: 4, ageCategory: AgeCategory.under16, gender: Gender.male, federation: 'SLCF', identificationNumber: 'MBA-004'),
        ],
      ),
      Team(
        id: 'team_c',
        name: 'Harbor Rooks',
        code: 'HR',
        countryOrClub: 'Galle District',
        captainName: 'Sahanika Wickramasinghe',
        seedRating: 2090,
        players: const [
          Player(id: 'c1', name: 'Amaya Gunasekara', rating: 2192, boardOrder: 1, ageCategory: AgeCategory.open, gender: Gender.female, federation: 'SLCF', identificationNumber: 'GDL-001'),
          Player(id: 'c2', name: 'Heshan Vithanage', rating: 2118, boardOrder: 2, ageCategory: AgeCategory.open, gender: Gender.male, federation: 'SLCF', identificationNumber: 'GDL-002'),
          Player(id: 'c3', name: 'Piumi Tharaka', rating: 2003, boardOrder: 3, ageCategory: AgeCategory.under18, gender: Gender.female, federation: 'SLCF', identificationNumber: 'GDL-003'),
          Player(id: 'c4', name: 'Yevan Rajapaksa', rating: 1966, boardOrder: 4, ageCategory: AgeCategory.under16, gender: Gender.male, federation: 'SLCF', identificationNumber: 'GDL-004'),
        ],
      ),
      Team(
        id: 'team_d',
        name: 'Capital Queens',
        code: 'CQ',
        countryOrClub: 'Starlight School',
        captainName: 'Dilini Abeysekara',
        seedRating: 2055,
        players: const [
          Player(id: 'd1', name: 'Nethmi Alwis', rating: 2174, boardOrder: 1, ageCategory: AgeCategory.open, gender: Gender.female, federation: 'SLCF', identificationNumber: 'SSL-001'),
          Player(id: 'd2', name: 'Kanishka Raman', rating: 2076, boardOrder: 2, ageCategory: AgeCategory.open, gender: Gender.male, federation: 'SLCF', identificationNumber: 'SSL-002'),
          Player(id: 'd3', name: 'Maya Wijekoon', rating: 1999, boardOrder: 3, ageCategory: AgeCategory.under18, gender: Gender.female, federation: 'SLCF', identificationNumber: 'SSL-003'),
          Player(id: 'd4', name: 'Dulin Hettige', rating: 1972, boardOrder: 4, ageCategory: AgeCategory.under16, gender: Gender.male, federation: 'SLCF', identificationNumber: 'SSL-004'),
        ],
      ),
    ];

    return [
      Tournament(
        id: 'sample_tournament',
        name: 'National Schools Team Chess Cup',
        location: 'BMICH, Colombo',
        startDate: DateTime(2026, 4, 3),
        endDate: DateTime(2026, 4, 5),
        numberOfRounds: 5,
        timeControl: '90+30',
        type: TournamentType.teamSwiss,
        notes: 'Sample tournament with seeded teams, board results, and standings.',
        pairingMethod: PairingMethod.teamSwiss,
        teams: teams,
        rounds: const [
          TournamentRound(
            roundNumber: 1,
            notes: 'Opening round generated from the team Swiss engine.',
            matches: [
              RoundMatch(
                id: 'm1',
                tableNumber: 1,
                homeTeamId: 'team_a',
                awayTeamId: 'team_d',
                outcome: MatchOutcome.homeWin,
                homeTeamScore: 3.0,
                awayTeamScore: 1.0,
                boardResults: [
                  BoardResult(boardNumber: 1, homePlayerId: 'a1', awayPlayerId: 'd1', homeScore: 1, awayScore: 0),
                  BoardResult(boardNumber: 2, homePlayerId: 'a2', awayPlayerId: 'd2', homeScore: 0.5, awayScore: 0.5),
                  BoardResult(boardNumber: 3, homePlayerId: 'a3', awayPlayerId: 'd3', homeScore: 0.5, awayScore: 0.5),
                  BoardResult(boardNumber: 4, homePlayerId: 'a4', awayPlayerId: 'd4', homeScore: 1, awayScore: 0),
                ],
              ),
              RoundMatch(
                id: 'm2',
                tableNumber: 2,
                homeTeamId: 'team_b',
                awayTeamId: 'team_c',
                outcome: MatchOutcome.draw,
                homeTeamScore: 2.0,
                awayTeamScore: 2.0,
                boardResults: [
                  BoardResult(boardNumber: 1, homePlayerId: 'b1', awayPlayerId: 'c1', homeScore: 0.5, awayScore: 0.5),
                  BoardResult(boardNumber: 2, homePlayerId: 'b2', awayPlayerId: 'c2', homeScore: 1, awayScore: 0),
                  BoardResult(boardNumber: 3, homePlayerId: 'b3', awayPlayerId: 'c3', homeScore: 0, awayScore: 1),
                  BoardResult(boardNumber: 4, homePlayerId: 'b4', awayPlayerId: 'c4', homeScore: 0.5, awayScore: 0.5),
                ],
              ),
            ],
          ),
        ],
        lastUpdated: DateTime(2026, 3, 15),
      ),
    ];
  }
}
