enum TournamentType {
  swiss,
  roundRobin,
  knockout,
  doubleRoundRobin,
  teamSwiss,
  scheveningen,
  custom,
}

enum PairingMethod {
  swiss,
  roundRobin,
  knockout,
  doubleRoundRobin,
  teamSwiss,
  scheveningen,
  custom,
}

enum AgeCategory {
  open,
  under8,
  under10,
  under12,
  under14,
  under16,
  under18,
  senior,
}

enum Gender { open, male, female, other }

enum MatchOutcome {
  pending,
  homeWin,
  awayWin,
  draw,
  forfeitHome,
  forfeitAway,
  bye,
}

extension TournamentTypeLabel on TournamentType {
  String get label {
    switch (this) {
      case TournamentType.swiss:
        return 'Swiss';
      case TournamentType.roundRobin:
        return 'Round-robin';
      case TournamentType.knockout:
        return 'Knockout';
      case TournamentType.doubleRoundRobin:
        return 'Double round-robin';
      case TournamentType.teamSwiss:
        return 'Team Swiss';
      case TournamentType.scheveningen:
        return 'Scheveningen';
      case TournamentType.custom:
        return 'Custom';
    }
  }
}

extension PairingMethodLabel on PairingMethod {
  String get label {
    switch (this) {
      case PairingMethod.swiss:
        return 'Swiss system';
      case PairingMethod.roundRobin:
        return 'Round-robin';
      case PairingMethod.knockout:
        return 'Knockout';
      case PairingMethod.doubleRoundRobin:
        return 'Double round-robin';
      case PairingMethod.teamSwiss:
        return 'Team Swiss';
      case PairingMethod.scheveningen:
        return 'Scheveningen';
      case PairingMethod.custom:
        return 'Manual / custom';
    }
  }
}

extension AgeCategoryLabel on AgeCategory {
  String get label {
    switch (this) {
      case AgeCategory.open:
        return 'Open';
      case AgeCategory.under8:
        return 'U8';
      case AgeCategory.under10:
        return 'U10';
      case AgeCategory.under12:
        return 'U12';
      case AgeCategory.under14:
        return 'U14';
      case AgeCategory.under16:
        return 'U16';
      case AgeCategory.under18:
        return 'U18';
      case AgeCategory.senior:
        return 'Senior';
    }
  }
}

extension GenderLabel on Gender {
  String get label {
    switch (this) {
      case Gender.open:
        return 'Open';
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }
}
