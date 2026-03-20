import 'package:chess_tournament/main.dart';
import 'package:chess_tournament/screens/splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app renders login choices on launch', (tester) async {
    await tester.pumpWidget(
      ChessTournamentApp(
        home: SplashScreen(
          onGoogleSignIn: () async {},
          onContinueAsGuest: () async {},
          isGoogleSignInAvailable: true,
        ),
      ),
    );

    expect(find.text('Chess Team Director'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);
  });
}
