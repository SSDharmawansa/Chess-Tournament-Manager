import 'package:chess_tournament/models/app_enums.dart';
import 'package:chess_tournament/models/pairing.dart';
import 'package:chess_tournament/pairing_engines/pairing_engine.dart';

class ManualPairingEngine implements PairingEngine {
  @override
  PairingProposal generate(PairingRequest request) {
    final matches = <RoundMatch>[
      for (var index = 0; index < request.teams.length; index += 2)
        if (index + 1 < request.teams.length)
          RoundMatch(
            id: 'manual_${request.roundNumber}_${index ~/ 2}',
            tableNumber: (index ~/ 2) + 1,
            homeTeamId: request.teams[index].id,
            awayTeamId: request.teams[index + 1].id,
            boardResults: const [],
            outcome: MatchOutcome.pending,
            notes: 'Review and edit this pairing manually.',
          )
        else
          RoundMatch(
            id: 'manual_${request.roundNumber}_bye',
            tableNumber: (index ~/ 2) + 1,
            homeTeamId: request.teams[index].id,
            awayTeamId: null,
            boardResults: const [],
            outcome: MatchOutcome.bye,
            homeTeamScore: 1,
            awayTeamScore: 0,
          ),
    ];

    return PairingProposal(
      roundNumber: request.roundNumber,
      matches: matches,
      notes:
          'Manual pairing template. Edit pairings before publishing the round.',
    );
  }
}
