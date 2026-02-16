import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/enum.dart';
import 'auth_service.dart';

final profileServiceProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return ProfileService(db, ref);
});

class ProfileService {
  final AppDatabase db;
  final Ref ref;

  ProfileService(this.db, this.ref);

  /// Créer un nouvel agent (Action réservée à l'Admin)
  Future<int> createAgent({
    required String nom,
    required String pin,
    double soldeInitial = 0.0,
  }) async {
    final admin = ref.read(currentUserProvider);

    return await db
        .into(db.profiles)
        .insert(
          ProfilesCompanion.insert(
            nom: nom,
            codePin: Value(pin),
            soldeCourant: Value(soldeInitial),
            role: const Value(RoleType.agent),
            adminId: Value(admin?.id), // Lie l'agent à l'admin qui l'a créé
          ),
        );
  }

  /// Créditer le compte d'un agent (Ravitaillement)
  Future<void> rechargeAgent(int agentId, double montant) async {
    final agent = await (db.select(
      db.profiles,
    )..where((t) => t.id.equals(agentId))).getSingle();

    await db.transaction(() async {
      // 1. Mise à jour du solde
      await (db.update(db.profiles)..where((t) => t.id.equals(agentId))).write(
        ProfilesCompanion(soldeCourant: Value(agent.soldeCourant + montant)),
      );

      // 2. Ajout d'un log d'activité pour la traçabilité
      await db
          .into(db.logActivities)
          .insert(
            LogActivitiesCompanion.insert(
              adminId: Value(ref.read(currentUserProvider)?.id),
              agentId: Value(agentId),
              action: "Ravitaillement de compte : +$montant Ar",
              ancienSolde: Value(agent.soldeCourant),
              nouveauSolde: Value(agent.soldeCourant + montant),
            ),
          );
    });
  }

  /// Stream des agents pour le Dashboard Admin
  Stream<List<Profile>> watchAllAgents() {
    return (db.select(
      db.profiles,
    )..where((t) => t.role.equals(RoleType.agent.index))).watch();
  }
}

final allAgentsProvider = StreamProvider<List<Profile>>((ref) {
  return ref.watch(profileServiceProvider).watchAllAgents();
});
