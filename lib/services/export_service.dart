import 'package:chess_tournament/models/app_enums.dart';
import 'package:chess_tournament/models/tournament.dart';

class ExportService {
  String buildSummary(Tournament tournament) {
    return [
      'Tournament: ${tournament.name}',
      'Location: ${tournament.location}',
      'Rounds: ${tournament.rounds.length}/${tournament.numberOfRounds}',
      'Teams: ${tournament.teams.length}',
      'Pairing: ${tournament.pairingMethod.label}',
      'Notes: ${tournament.notes}',
    ].join('\n');
  }
}
