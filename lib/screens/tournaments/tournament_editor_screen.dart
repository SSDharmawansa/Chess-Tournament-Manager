import 'package:chess_tournament/models/app_enums.dart';
import 'package:chess_tournament/models/tournament.dart';
import 'package:chess_tournament/state/tournament_controller.dart';
import 'package:chess_tournament/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TournamentEditorScreen extends ConsumerStatefulWidget {
  const TournamentEditorScreen({
    super.key,
    this.initialTournament,
  });

  final Tournament? initialTournament;

  @override
  ConsumerState<TournamentEditorScreen> createState() =>
      _TournamentEditorScreenState();
}

class _TournamentEditorScreenState extends ConsumerState<TournamentEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _timeControlController;
  late final TextEditingController _roundsController;
  late final TextEditingController _notesController;
  late DateTimeRange _dateRange;
  late TournamentType _type;
  late PairingMethod _pairingMethod;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTournament;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _locationController = TextEditingController(text: initial?.location ?? '');
    _timeControlController = TextEditingController(text: initial?.timeControl ?? '90+30');
    _roundsController =
        TextEditingController(text: '${initial?.numberOfRounds ?? 5}');
    _notesController = TextEditingController(text: initial?.notes ?? '');
    _dateRange = DateTimeRange(
      start: initial?.startDate ?? DateTime.now(),
      end: initial?.endDate ?? DateTime.now().add(const Duration(days: 2)),
    );
    _type = initial?.type ?? TournamentType.teamSwiss;
    _pairingMethod = initial?.pairingMethod ?? PairingMethod.teamSwiss;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _timeControlController.dispose();
    _roundsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialTournament == null ? 'Create Tournament' : 'Edit Tournament'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SectionCard(
                title: 'Tournament Details',
                subtitle: 'Configure the organizer-facing event setup.',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Tournament name'),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Enter a tournament name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Enter a location'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _roundsController,
                            decoration: const InputDecoration(labelText: 'Rounds'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final rounds = int.tryParse(value ?? '');
                              if (rounds == null || rounds < 1) {
                                return 'Enter valid rounds';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _timeControlController,
                            decoration: const InputDecoration(labelText: 'Time control'),
                            validator: (value) => value == null || value.trim().isEmpty
                                ? 'Enter time control'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TournamentType>(
                      initialValue: _type,
                      decoration: const InputDecoration(labelText: 'Tournament type'),
                      items: TournamentType.values
                          .map((type) => DropdownMenuItem(value: type, child: Text(type.label)))
                          .toList(),
                      onChanged: (value) => setState(() => _type = value!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<PairingMethod>(
                      initialValue: _pairingMethod,
                      decoration: const InputDecoration(labelText: 'Pairing method'),
                      items: PairingMethod.values
                          .map(
                            (method) =>
                                DropdownMenuItem(value: method, child: Text(method.label)),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _pairingMethod = value!),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      title: const Text('Start and end dates'),
                      subtitle: Text(
                        '${_dateRange.start.day}/${_dateRange.start.month}/${_dateRange.start.year} - ${_dateRange.end.day}/${_dateRange.end.month}/${_dateRange.end.year}',
                      ),
                      trailing: const Icon(Icons.date_range),
                      onTap: () async {
                        final result = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2035),
                          initialDateRange: _dateRange,
                        );
                        if (result != null) {
                          setState(() => _dateRange = result);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Notes / description'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save tournament'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(tournamentControllerProvider.notifier);
    final initial = widget.initialTournament;
    final tournament = Tournament(
      id: initial?.id ?? 't_${DateTime.now().microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      startDate: _dateRange.start,
      endDate: _dateRange.end,
      numberOfRounds: int.parse(_roundsController.text.trim()),
      timeControl: _timeControlController.text.trim(),
      type: _type,
      notes: _notesController.text.trim(),
      pairingMethod: _pairingMethod,
      teams: initial?.teams ?? const [],
      rounds: initial?.rounds ?? const [],
      lastUpdated: DateTime.now(),
    );

    await controller.saveTournament(tournament);
    if (mounted) Navigator.of(context).pop();
  }
}
