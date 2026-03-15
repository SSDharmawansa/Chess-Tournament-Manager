import 'package:chess_tournament/models/app_enums.dart';
import 'package:chess_tournament/models/pairing.dart';
import 'package:chess_tournament/models/standing.dart';
import 'package:chess_tournament/models/team.dart';
import 'package:chess_tournament/models/tournament.dart';
import 'package:chess_tournament/pairing_engines/manual_pairing_engine.dart';
import 'package:chess_tournament/pairing_engines/round_robin_engine.dart';
import 'package:chess_tournament/pairing_engines/swiss_engine.dart';

class PairingRequest {
  const PairingRequest({
    required this.tournament,
    required this.teams,
    required this.standings,
    required this.roundNumber,
  });

  final Tournament tournament;
  final List<Team> teams;
  final List<TeamStanding> standings;
  final int roundNumber;
}

class PairingProposal {
  const PairingProposal({
    required this.roundNumber,
    required this.matches,
    required this.notes,
  });

  final int roundNumber;
  final List<RoundMatch> matches;
  final String notes;
}

abstract class PairingEngine {
  PairingProposal generate(PairingRequest request);
}

class PairingEngineFactory {
  static PairingEngine create(PairingMethod method) {
    switch (method) {
      case PairingMethod.swiss:
      case PairingMethod.teamSwiss:
      case PairingMethod.scheveningen:
      case PairingMethod.knockout:
        return SwissPairingEngine();
      case PairingMethod.roundRobin:
      case PairingMethod.doubleRoundRobin:
        return RoundRobinPairingEngine();
      case PairingMethod.custom:
        return ManualPairingEngine();
    }
  }
}
