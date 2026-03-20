import 'package:chess_tournament/models/tournament.dart';
import 'package:chess_tournament/storage/tournament_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTournamentRepository implements TournamentRepository {
  FirestoreTournamentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('tournaments');

  @override
  Future<List<Tournament>> loadTournaments() async {
    final snapshot = await _collection.get();
    final tournaments = snapshot.docs.map((doc) {
      final data = doc.data();
      return Tournament.fromJson({...data, 'id': data['id'] ?? doc.id});
    }).toList();

    tournaments.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return tournaments;
  }

  @override
  Future<void> saveTournament(Tournament tournament) {
    return _collection.doc(tournament.id).set(tournament.toJson());
  }

  @override
  Future<void> saveTournaments(List<Tournament> tournaments) async {
    final batch = _firestore.batch();

    for (final tournament in tournaments) {
      batch.set(_collection.doc(tournament.id), tournament.toJson());
    }

    await batch.commit();
  }
}
