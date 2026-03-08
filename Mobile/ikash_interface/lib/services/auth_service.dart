import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/enum.dart';
import '../database/database_seeder.dart';

// 1. Le Provider pour la Base de données
final databaseProvider = Provider((ref) => AppDatabase());

// 2. Le Notifier pour l'utilisateur actuel (Nouvelle syntaxe Riverpod)
class CurrentUserNotifier extends Notifier<Profile?> {
  @override
  Profile? build() => null;

  void setUser(Profile? user) => state = user;
}

final currentUserProvider = NotifierProvider<CurrentUserNotifier, Profile?>(() {
  return CurrentUserNotifier();
});

// 3. Le Service d'Authentification
class AuthService {
  final AppDatabase db;
  final Ref ref;

  AuthService(this.db, this.ref);

  /// Initialisation : Crée les comptes par défaut si la base est vide
  Future<void> seedDatabase() async {
    final allProfiles = await db.select(db.profiles).get();

    if (allProfiles.isEmpty) {
      // Compte Admin par défaut
      await db
          .into(db.profiles)
          .insert(
            ProfilesCompanion.insert(
              nom: 'Administrateur',
              codePin: const Value('0000'), // Utilisation de Value() pour Drift
              role: const Value(RoleType.admin),
            ),
          );

      // Compte Agent par défaut
      await db
          .into(db.profiles)
          .insert(
            ProfilesCompanion.insert(
              nom: 'Agent iKash',
              codePin: const Value('1234'), // Utilisation de Value() pour Drift
              role: const Value(RoleType.agent),
            ),
          );
    }
    await db.seedTarifsInitiaux();
  }

  /// Tentative de connexion via PIN
  // Dans ton AuthService ou AppDatabase
  /// Tentative de connexion via PIN
  Future<Profile?> login(String pin) async {
    // On utilise db.select et db.profiles
    final user = await (db.select(
      db.profiles,
    )..where((t) => t.codePin.equals(pin))).getSingleOrNull();

    if (user != null) {
      // Si l'utilisateur est trouvé, on met à jour le provider de session
      ref.read(currentUserProvider.notifier).setUser(user);
    }

    return user;
  }

  // Dans AuthService
  Future<void> logout() async {
    // On remet l'utilisateur à null
    ref.read(currentUserProvider.notifier).setUser(null);
    // Optionnel : tu peux aussi vider d'autres états ici si nécessaire
  }
}

// 4. Le Provider pour le Service Auth
final authServiceProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return AuthService(db, ref);
});

final allPendingSmsProvider = StreamProvider<List<SmsReceivedData>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllPendingSms();
});
final currentAgentIdProvider = Provider<int>((ref) {
  final profile = ref.watch(currentUserProvider);
  // Si pas de profil (déconnecté), on retourne 0 ou un ID invalide
  return profile?.id ?? 0;
});
// Provider qui récupère les puces pour un ID spécifique
final agentPucesProvider = StreamProvider.family<List<AgentNumber>, int>((
  ref,
  agentId,
) {
  return ref.watch(databaseProvider).watchAgentNumbers(agentId);
});

// 2. On branche les puces sur cet ID
final allPucesProvider = StreamProvider<List<AgentNumber>>((ref) {
  final db = ref.watch(databaseProvider);
  final agentId = ref.watch(currentAgentIdProvider);

  // Si l'agent est 0 (non connecté), on retourne une liste vide
  if (agentId == 0) return Stream.value([]);

  return db.watchAgentNumbers(agentId);
});
