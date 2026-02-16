// lib/providers/history_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../services/auth_service.dart';
import 'package:drift/drift.dart'; // Vérifie que cet import est présent

final historyStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(databaseProvider);
  // On récupère les transactions triées par date décroissante
  return (db.select(
    db.transactions,
  )..orderBy([(t) => OrderingTerm.desc(t.horodatage)])).watch();
});
