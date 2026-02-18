import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/app_database.dart';
import '../services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupService {
  final AppDatabase db;

  BackupService(this.db);

  // --- EXPORTATION ---
  Future<void> exportBackup() async {
    // 1. Récupérer toutes les données des tables importantes
    final allProfiles = await db.select(db.profiles).get();
    final allPuces = await db.select(db.agentNumbers).get();
    final allTransactions = await db.select(db.transactions).get();
    final allLogs = await db.select(db.logActivities).get();

    // 2. Créer une structure Map (JSON)
    Map<String, dynamic> backupData = {
      "version": 1,
      "date": DateTime.now().toIso8601String(),
      "profiles": allProfiles.map((e) => e.toJson()).toList(),
      "puces": allPuces.map((e) => e.toJson()).toList(),
      "transactions": allTransactions.map((e) => e.toJson()).toList(),
      "LogActivities": allLogs.map((e) => e.toJson()).toList(),
    };

    // 3. Convertir en String et enregistrer temporairement
    String jsonString = jsonEncode(backupData);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/ikash_backup.json');
    await file.writeAsString(jsonString);

    // 4. Partager le fichier
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Sauvegarde iKash Mobile');
  }
  // --- IMPORTATION ---

  Future<bool> importBackup(String jsonContent) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonContent);

      await db.transaction(() async {
        // 1. Restaurer les Profils
        for (var p in data['profiles']) {
          // On utilise le parseur de la classe de données générée
          final entity = Profile.fromJson(p);
          await db.into(db.profiles).insertOnConflictUpdate(entity);
        }

        // 2. Restaurer les Puces
        for (var puce in data['puces']) {
          // Vérifie si le nom généré est AgentNumber ou AgentNumbersData
          final entity = AgentNumber.fromJson(puce);
          await db.into(db.agentNumbers).insertOnConflictUpdate(entity);
        }

        // 3. Restaurer les Transactions
        for (var tx in data['transactions']) {
          // Vérifie si le nom généré est Transaction ou TransactionsData
          final entity = Transaction.fromJson(tx);
          await db.into(db.transactions).insertOnConflictUpdate(entity);
        }
      });
      return true;
    } catch (e) {
      print("Erreur d'import détaillé : $e");
      return false;
    }
  }
}

// Provider pour le service
final backupServiceProvider = Provider(
  (ref) => BackupService(ref.watch(databaseProvider)),
);
