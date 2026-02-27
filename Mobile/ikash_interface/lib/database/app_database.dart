import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import de modèles
import '../models/enum.dart';
import '../models/profiles.dart';
import '../models/transactions.dart';
import '../models/logactivities.dart';
import '../models/sms_received.dart';
import '../models/agent_numbers.dart';
import '../models/tarif.dart';

// C'est ici que la magie de la génération opère
part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Profiles,
    Transactions,
    LogActivities,
    Tarifs,
    SmsReceived,
    AgentNumbers,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3; // À augmenter si ON modifies tes tables plus tard

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 1) {
          await m.addColumn(transactions, transactions.nomClient);
        }
        if (from < 2) {
          // 1. On crée la nouvelle table
          await m.createTable(agentNumbers);
          // 2. On ajoute la colonne de liaison dans Transactions
          await m.addColumn(transactions, transactions.agentNumberId);
        }
        // <--- MIGRATION POUR LA NOUVELLE TABLE
        if (from < 3) {
          await m.createTable(tarifs);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // --- REQUÊTES FACILES (Exemples) ---

  // Pour le Login : Vérifier le code PIN
  Future<Profile?> getProfileByPin(String pin) {
    return (select(
      profiles,
    )..where((t) => t.codePin.equals(pin))).getSingleOrNull();
  }

  // Pour le Dashboard : Voir les transactions en temps réel
  // Pour le Dashboard et les Logs : Voir les transactions du plus récent au plus ancien
  // Pour les Transactions
  Stream<List<Transaction>> watchAllTransactions() {
    return (select(transactions)..orderBy([
          (t) => OrderingTerm.desc(t.horodatage),
        ])) // Syntaxe directe .desc()
        .watch();
  }

  // Ajouter une transaction (SMS parsé)
  Future<int> addTransaction(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  // Compteur de SMS
  Stream<int> countPendingSms() {
    return (select(smsReceived)..where((t) => t.estTraite.equals(false)))
        .watch()
        .map((list) => list.length);
  }

  // Surveillance en temps réel de TOUTES les puces (utile pour le UI dynamique)
  Stream<List<AgentNumber>> watchAllAgentNumbers() {
    return select(agentNumbers).watch();
  }

  // Récupération ponctuelle de TOUTES les puces (pour ton handleSave)
  Future<List<AgentNumber>> getAllAgentNumbers() {
    return select(agentNumbers).get();
  }

  // Dans ta classe AppDatabase
  Future<void> repairMissingAgentLinks() async {
    final allTx = await select(transactions).get();
    final allPuces = await getAllAgentNumbers();

    for (var tx in allTx) {
      if (tx.agentNumberId == null) {
        try {
          // On cherche la puce qui a le même opérateur que la transaction
          final correctPuce = allPuces.firstWhere(
            (p) => p.operateur == tx.operateur,
          );

          // On met à jour la transaction avec l'ID de cette puce
          await (update(transactions)..where((t) => t.id.equals(tx.id))).write(
            TransactionsCompanion(agentNumberId: Value(correctPuce.id)),
          );

          print("Lien réparé pour la transaction ${tx.reference}");
        } catch (e) {
          print(
            "Impossible de réparer ${tx.reference} : aucune puce trouvée pour cet opérateur",
          );
        }
      }
    }
  }

  // Dans ta classe AppDatabase
  Stream<List<SmsReceivedData>> watchAllPendingSms() {
    return (select(
      smsReceived,
    )..where((t) => t.estTraite.equals(false))).watch();
  }

  Stream<List<SmsReceivedData>> watchAllSms() {
    return (select(smsReceived)..orderBy([
          (t) => OrderingTerm.desc(t.dateReception),
        ])) // Syntaxe directe .desc()
        .watch();
  }

  // 1. Service pour surveiller les puces d'un agent en temps réel (Stream)
  Stream<List<AgentNumber>> watchAgentNumbers(int profileId) {
    return (select(
      agentNumbers,
    )..where((t) => t.profileId.equals(profileId))).watch();
  }

  // 2. Service pour ajouter ou mettre à jour une puce (Upsert)
  Future<int> saveAgentNumber(AgentNumbersCompanion entry) {
    return into(agentNumbers).insertOnConflictUpdate(entry);
  }

  // 3. Service pour récupérer une puce spécifique par opérateur
  Future<AgentNumber?> getPuceByOperator(int profileId, OperatorType op) {
    return (select(agentNumbers)
          ..where((t) => t.profileId.equals(profileId))
          ..where((t) => t.operateur.equals(op.index)))
        .getSingleOrNull();
  }

  // Dans AppDatabase
  Stream<Profile> watchProfile(int id) {
    return (select(profiles)..where((t) => t.id.equals(id))).watchSingle();
  }
}

// Configuration de l'emplacement du fichier SQLite sur le téléphone
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ikash_offline.sqlite'));
    return NativeDatabase(file);
  });
}
