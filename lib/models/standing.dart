class TeamStanding {
  const TeamStanding({
    required this.rank,
    required this.teamId,
    required this.teamName,
    required this.seedRating,
    required this.matchesPlayed,
    required this.matchPoints,
    required this.gamePoints,
    required this.buchholz,
    required this.sonnebornBerger,
    required this.wins,
    required this.draws,
    required this.losses,
  });

  final int rank;
  final String teamId;
  final String teamName;
  final int seedRating;
  final int matchesPlayed;
  final double matchPoints;
  final double gamePoints;
  final double buchholz;
  final double sonnebornBerger;
  final int wins;
  final int draws;
  final int losses;
}
