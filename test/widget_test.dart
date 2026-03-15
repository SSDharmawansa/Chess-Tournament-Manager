import 'package:chess_tournament/main.dart';
import 'package:chess_tournament/state/tournament_controller.dart';
import 'package:chess_tournament/storage/local_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('app renders splash screen shell', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localStorageServiceProvider.overrideWithValue(LocalStorageService())],
        child: const ChessTournamentApp(),
      ),
    );

    expect(find.text('Chess Team Director'), findsOneWidget);
  });
}
