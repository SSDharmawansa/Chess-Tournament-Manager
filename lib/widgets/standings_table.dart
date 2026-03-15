import 'package:chess_tournament/core/formatters.dart';
import 'package:chess_tournament/models/standing.dart';
import 'package:flutter/material.dart';

class StandingsTable extends StatelessWidget {
  const StandingsTable({
    super.key,
    required this.standings,
  });

  final List<TeamStanding> standings;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('#')),
          DataColumn(label: Text('Team')),
          DataColumn(label: Text('MP')),
          DataColumn(label: Text('GP')),
          DataColumn(label: Text('Buchholz')),
          DataColumn(label: Text('S-B')),
          DataColumn(label: Text('W-D-L')),
        ],
        rows: standings
            .map(
              (standing) => DataRow(
                cells: [
                  DataCell(Text('${standing.rank}')),
                  DataCell(Text(standing.teamName)),
                  DataCell(Text(AppFormatters.score(standing.matchPoints))),
                  DataCell(Text(AppFormatters.score(standing.gamePoints))),
                  DataCell(Text(AppFormatters.score(standing.buchholz))),
                  DataCell(Text(AppFormatters.score(standing.sonnebornBerger))),
                  DataCell(Text('${standing.wins}-${standing.draws}-${standing.losses}')),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
