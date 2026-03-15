import 'package:chess_tournament/core/formatters.dart';
import 'package:chess_tournament/models/pairing.dart';
import 'package:chess_tournament/models/team.dart';
import 'package:flutter/material.dart';

class RoundMatchTile extends StatelessWidget {
  const RoundMatchTile({
    super.key,
    required this.match,
    required this.homeTeam,
    required this.awayTeam,
    this.onEditPairing,
    this.onEnterResult,
  });

  final RoundMatch match;
  final Team homeTeam;
  final Team? awayTeam;
  final VoidCallback? onEditPairing;
  final VoidCallback? onEnterResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        title: Text('Table ${match.tableNumber}'),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${homeTeam.name} vs ${awayTeam?.name ?? 'Bye'}'),
              const SizedBox(height: 6),
              Text(
                '${AppFormatters.score(match.homeTeamScore)} : ${AppFormatters.score(match.awayTeamScore)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppFormatters.scoreColor(
                    context,
                    match.homeTeamScore,
                    match.awayTeamScore,
                  ),
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (match.notes.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  match.notes,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEditPairing?.call();
            if (value == 'result') onEnterResult?.call();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit pairing')),
            PopupMenuItem(value: 'result', child: Text('Enter result')),
          ],
        ),
      ),
    );
  }
}
