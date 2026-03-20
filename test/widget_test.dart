import 'package:chess_tournament/main.dart';
import 'package:chess_tournament/models/tournament.dart';
import 'package:chess_tournament/state/tournament_controller.dart';
import 'package:chess_tournament/storage/tournament_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('app renders splash screen shell', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tournamentRepositoryProvider.overrideWithValue(
            _FakeTournamentRepository(),
          ),
        ],
        child: const ChessTournamentApp(),
      ),
    );

    expect(find.text('Chess Team Director'), findsOneWidget);
  });
}

class _FakeTournamentRepository implements TournamentRepository {
  @override
  Future<List<Tournament>> loadTournaments() async => [];

  @override
  Future<void> saveTournament(Tournament tournament) async {}

  @override
  Future<void> saveTournaments(List<Tournament> tournaments) async {}
}
