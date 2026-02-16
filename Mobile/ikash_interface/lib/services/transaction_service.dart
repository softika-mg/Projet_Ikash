import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import 'auth_service.dart';
import '../models/enum.dart';

final transactionControllerProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionController(db, ref);
});

class TransactionController {
  final AppDatabase db;
  final Ref ref;

  TransactionController(this.db, this.ref);

  Future<List<AgentNumber>> getAllAgentNumbers() async {
    return await db.select(db.agentNumbers).get();
  }

  /// Enregistre une transaction, met à jour le solde global ET le solde de la puce utilisée
  Future<void> saveTransaction(TransactionsCompanion entry) async {
    final profile = ref.read(currentUserProvider);
    if (profile == null) throw Exception("Aucun agent connecté");

    await db.transaction(() async {
      // 1. CHERCHER LA PUCE CORRESPONDANTE (Traçabilité)
      // On cherche si l'agent a enregistré un numéro pour cet opérateur
      final puce =
          await (db.select(db.agentNumbers)
                ..where((t) => t.profileId.equals(profile.id))
                ..where((t) => t.operateur.equals(entry.operateur.value.index)))
              .getSingleOrNull();

      // On prépare la transaction avec l'ID de la puce (si elle existe)
      final finalEntry = entry.copyWith(
        agentId: Value(profile.id),
        agentNumberId: puce != null ? Value(puce.id) : const Value.absent(),
      );

      // 2. INSÉRER LA TRANSACTION
      await db.addTransaction(finalEntry);

      // 3. CALCULER L'IMPACT FINANCIER
      final type = entry.type.value;
      final montant = entry.montant.value;
      // Dépôt : Le solde diminue car l'argent sort de la caisse/puce
      // Retrait : Le solde augmente car l'argent entre
      double impact = (type == TransactionType.depot) ? -montant : montant;

      final nouveauSoldeGlobal = profile.soldeCourant + impact;

      // 4. MISE À JOUR DU SOLDE GLOBAL (Table Profiles)
      await (db.update(db.profiles)..where((t) => t.id.equals(profile.id)))
          .write(ProfilesCompanion(soldeCourant: Value(nouveauSoldeGlobal)));

      // 5. MISE À JOUR DU SOLDE DE LA PUCE (Table AgentNumbers)
      if (puce != null) {
        final nouveauSoldePuce = puce.soldePuce + impact;
        await (db.update(db.agentNumbers)..where((t) => t.id.equals(puce.id)))
            .write(AgentNumbersCompanion(soldePuce: Value(nouveauSoldePuce)));
      }

      // 6. LOGUER L'ACTIVITÉ
      await db
          .into(db.logActivities)
          .insert(
            LogActivitiesCompanion.insert(
              agentId: Value(profile.id),
              action:
                  '${type.name.toUpperCase()} ${entry.operateur.value.name.toUpperCase()} de ${montant.toInt()} Ar',
              ancienSolde: Value(profile.soldeCourant),
              nouveauSolde: Value(nouveauSoldeGlobal),
            ),
          );

      // 7. RAFRAÎCHIR L'ÉTAT DE L'UTILISATEUR
      final updatedProfile = await (db.select(
        db.profiles,
      )..where((t) => t.id.equals(profile.id))).getSingle();
      ref.read(currentUserProvider.notifier).setUser(updatedProfile);
    });
  }
}
