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

  Future<TarifData?> getTarifFor(OperatorType op, double montant) async {
    return await (db.select(db.tarifs)
          ..where((t) => t.operateur.equals(op.index))
          ..where((t) => t.montantMin.isSmallerOrEqualValue(montant))
          ..where((t) => t.montantMax.isBiggerOrEqualValue(montant)))
        .getSingleOrNull();
  }

  Future<void> saveTransaction(TransactionsCompanion entry) async {
    final authProfile = ref.read(currentUserProvider);
    if (authProfile == null) throw Exception("Aucun agent connecté");

    await db.transaction(() async {
      // RE-LECTURE DU PROFIL (Sécurité contre les accès concurrents)
      final currentProfile = await (db.select(
        db.profiles,
      )..where((t) => t.id.equals(authProfile.id))).getSingle();

      // 1. Chercher la puce DIRECTEMENT par son ID
      final puce =
          await (db.select(db.agentNumbers)..where(
                (t) => t.id.equals(entry.agentNumberId.value!),
              )) // Utilisez l'ID passé par la vue
              .getSingleOrNull();

      if (puce == null)
        throw Exception("Puce non trouvée (ID: ${entry.agentNumberId.value})");

      // 2. Calcul des impacts (Arrondis pour éviter les bugs de virgule flottante)
      final type = entry.type.value;
      final montant = entry.montant.value;
      final double fraisOp = entry.fraisOperateur.present
          ? (entry.fraisOperateur.value ?? 0.0)
          : 0.0;

      double impactPuce = (type == TransactionType.depot)
          ? -(montant + fraisOp)
          : montant;
      impactPuce = impactPuce.roundToDouble();

      // 3. Validation Anti-Solde Négatif
      if (puce.soldePuce + impactPuce < 0) {
        throw Exception("Solde insuffisant sur la puce (${puce.soldePuce} Ar)");
      }

      // 4. Insertion de la transaction
      await db.addTransaction(
        entry.copyWith(
          agentId: Value(currentProfile.id),
          agentNumberId: Value(puce.id),
        ),
      );

      // 5. Mise à jour atomique des soldes
      await (db.update(
        db.agentNumbers,
      )..where((t) => t.id.equals(puce.id))).write(
        AgentNumbersCompanion(soldePuce: Value(puce.soldePuce + impactPuce)),
      );

      final nouveauSoldeGlobal = (currentProfile.soldeCourant + impactPuce)
          .roundToDouble();
      await (db.update(db.profiles)
            ..where((t) => t.id.equals(currentProfile.id)))
          .write(ProfilesCompanion(soldeCourant: Value(nouveauSoldeGlobal)));

      // 6. Logs
      await db
          .into(db.logActivities)
          .insert(
            LogActivitiesCompanion.insert(
              agentId: Value(currentProfile.id),
              action:
                  '${type.name.toUpperCase()} ${entry.operateur.value.name} : $montant Ar',
              ancienSolde: Value(currentProfile.soldeCourant),
              nouveauSolde: Value(nouveauSoldeGlobal),
            ),
          );

      // 7. Refresh UI (On informe le notifier du changement)
      final updatedProfile = await (db.select(
        db.profiles,
      )..where((t) => t.id.equals(currentProfile.id))).getSingle();
      ref.read(currentUserProvider.notifier).setUser(updatedProfile);
    });
  }

  // À ajouter dans la classe TransactionController
  Stream<List<AgentNumber>> watchAllAgentNumbers() {
    final authProfile = ref.read(currentUserProvider);
    if (authProfile == null) return Stream.value([]);

    return (db.select(db.agentNumbers).watch());
  }

  /// Méthode pour la recharge ou le compte-rendu (Interface dédiée)
  Future<void> adjustBalance({
    required int puceId,
    required double montant,
    required bool
    isRecharge, // true = recharge (+), false = versement admin (-)
  }) async {
    await db.transaction(() async {
      final puce = await (db.select(
        db.agentNumbers,
      )..where((t) => t.id.equals(puceId))).getSingle();
      final profile = ref.read(currentUserProvider)!;

      double impact = isRecharge ? montant : -montant;

      if (puce.soldePuce + impact < 0)
        throw Exception("Solde insuffisant pour ce versement");

      await (db.update(
        db.agentNumbers,
      )..where((t) => t.id.equals(puceId))).write(
        AgentNumbersCompanion(soldePuce: Value(puce.soldePuce + impact)),
      );

      await (db.update(
        db.profiles,
      )..where((t) => t.id.equals(profile.id))).write(
        ProfilesCompanion(soldeCourant: Value(profile.soldeCourant + impact)),
      );

      // Log spécifique pour le compte-rendu
      await db
          .into(db.logActivities)
          .insert(
            LogActivitiesCompanion.insert(
              agentId: Value(profile.id),
              action: isRecharge ? 'RECHARGE PUCE' : 'VERSEMENT COMPTE-RENDU',
              ancienSolde: Value(profile.soldeCourant),
              nouveauSolde: Value(profile.soldeCourant + impact),
            ),
          );
    });
  }
}
