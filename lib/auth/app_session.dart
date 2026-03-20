import 'package:chess_tournament/storage/tournament_repository.dart';

enum AppSessionMode { guest, google }

class AppSession {
  AppSession.guest({required this.repository})
    : mode = AppSessionMode.guest,
      displayName = 'Guest workspace',
      subtitle = 'Saved on this device';

  AppSession.google({
    required this.repository,
    String? displayName,
    String? email,
  }) : mode = AppSessionMode.google,
       displayName = (displayName != null && displayName.trim().isNotEmpty)
           ? displayName
           : (email != null && email.trim().isNotEmpty)
           ? email
           : 'Google workspace',
       subtitle = (email != null && email.trim().isNotEmpty)
           ? email
           : 'Signed in with Google';

  final AppSessionMode mode;
  final String displayName;
  final String subtitle;
  final TournamentRepository repository;

  bool get isGuest => mode == AppSessionMode.guest;
}
