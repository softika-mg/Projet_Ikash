import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import de tes modèles
import '../models/enum.dart';
import '../models/profiles.dart';
import '../models/transactions.dart';
import '../models/logactivities.dart';

// C'est ici que la magie de la génération opère
part 'app_database.g.dart';

@DriftDatabase(tables: [Profiles, Transactions, LogActivities])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1; // À augmenter si tu modifies tes tables plus tard

  // --- REQUÊTES FACILES (Exemples) ---

  // Pour le Login : Vérifier le code PIN
  Future<Profile?> getProfileByPin(String pin) {
    return (select(
      profiles,
    )..where((t) => t.codePin.equals(pin))).getSingleOrNull();
  }

  // Pour le Dashboard : Voir les transactions en temps réel
  Stream<List<Transaction>> watchAllTransactions() =>
      select(transactions).watch();

  // Ajouter une transaction (SMS parsé)
  Future<int> addTransaction(TransactionsCompanion entry) =>
      into(transactions).insert(entry);
}

// Configuration de l'emplacement du fichier SQLite sur le téléphone
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ikash_offline.sqlite'));
    return NativeDatabase(file);
  });
}
