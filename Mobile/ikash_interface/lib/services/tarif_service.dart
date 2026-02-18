import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../models/enum.dart';
import '../services/auth_service.dart';

class TarifService {
  final AppDatabase db;
  TarifService(this.db);

  // Vérifie bien dans ton fichier .g.dart si c'est TarifData ou TarifsData
  Future<TarifData?> chercherTarif(double montant, OperatorType op) async {
    try {
      final query = db.select(db.tarifs)
        ..where((t) => t.operateur.equals(op.index))
        // On utilise la syntaxe la plus explicite de Drift
        ..where((t) => t.montantMin.isSmallerOrEqualValue(montant))
        ..where((t) => t.montantMax.isBiggerOrEqualValue(montant));

      return await query.getSingleOrNull();
    } catch (e) {
      debugPrint("Erreur recherche tarif : $e");
      return null;
    }
  }

  Stream<List<TarifData>> watchTousLesTarifs() {
    return (db.select(db.tarifs)..orderBy([
          (t) => OrderingTerm.asc(t.operateur),
          (t) => OrderingTerm.asc(t.montantMin),
        ]))
        .watch();
  }

  // 2. Supprimer un tarif
  Future<int> supprimerTarif(int id) {
    return (db.delete(db.tarifs)..where((t) => t.id.equals(id))).go();
  }

  // 3. Ajouter ou mettre à jour (Upsert)
  Future<void> upsertTarif(TarifsCompanion entry) {
    return db.into(db.tarifs).insertOnConflictUpdate(entry);
  }
}

final tarifServiceProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return TarifService(db);
});
final tarifsStreamProvider = StreamProvider<List<TarifData>>((ref) {
  return ref.watch(tarifServiceProvider).watchTousLesTarifs();
});
