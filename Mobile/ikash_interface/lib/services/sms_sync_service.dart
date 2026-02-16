import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

import '../database/app_database.dart';
import 'auth_service.dart';
import '../models/enum.dart';
import 'sms_engine_service.dart';

final smsSyncProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  // On passe 'ref' au service pour qu'il puisse lire le currentUserProvider
  return SmsSyncService(db, ref);
});

class SmsSyncService {
  final AppDatabase db;
  final Ref ref;

  SmsSyncService(this.db, this.ref);

  Future<void> fetchAndParseSms() async {
    final SmsQuery query = SmsQuery();

    List<SmsMessage> messages = await query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: 10,
    );

    for (var sms in messages) {
      final data = SmsEngineService.parseSms(sms.body ?? '', sms.address ?? '');

      if (data != null) {
        try {
          // CORRECTION ICI : Pas de Value() pour les champs requis dans .insert()
          await db
              .into(db.smsReceived)
              .insert(
                SmsReceivedCompanion.insert(
                  rawBody: sms.body!,
                  sender: sms.address!,
                  // On caste explicitement car 'data' est un Map<String, dynamic>
                  operateur: data['operateur'] as OperatorType,
                  type: data['type'] as TransactionType,
                  montant: data['montant'] as double,
                  reference: data['reference'] as String,
                  // numeroClient est nullable dans ta table, donc il accepte une Value()
                  numeroClient: Value(data['numeroClient'] as String?),
                ),
              );
          print("SMS iKash détecté : ${data['reference']}");
        } catch (e) {
          // Erreur attendue si la référence (UNIQUE) existe déjà
        }
      }
    }
  }

  Future<void> markAsProcessed(int id) async {
    // Dans un .write() (Update), on utilise obligatoirement Value()
    await (db.update(db.smsReceived)..where((t) => t.id.equals(id))).write(
      const SmsReceivedCompanion(estTraite: Value(true)),
    );
  }

  Future<void> validateSmsAsTransaction(SmsReceivedData sms) async {
    // 1. On récupère l'utilisateur actuel pour mettre à jour son solde
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    // 2. On utilise une transaction SQLite pour garantir que tout est fait ou rien
    await db.transaction(() async {
      // A. Créer la transaction officielle
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: Value(sms.type) as TransactionType,
              montant: sms.montant,
              reference: sms.reference,
              operateur: Value(sms.operateur) as OperatorType,
              horodatage: Value(DateTime.now()),
              agentId: currentUser.id,
            ),
          );

      // B. Mettre à jour le solde de l'agent
      final nouveauSolde = sms.type == TransactionType.depot
          ? currentUser.soldeCourant + sms.montant
          : currentUser.soldeCourant - sms.montant;

      await (db.update(db.profiles)..where((t) => t.id.equals(currentUser.id)))
          .write(ProfilesCompanion(soldeCourant: Value(nouveauSolde)));

      // C. Marquer le SMS comme traité pour qu'il disparaisse du sas
      await (db.update(db.smsReceived)..where((t) => t.id.equals(sms.id)))
          .write(const SmsReceivedCompanion(estTraite: Value(true)));

      // D. Mettre à jour l'état de l'utilisateur dans l'app
      ref
          .read(currentUserProvider.notifier)
          .setUser(currentUser.copyWith(soldeCourant: nouveauSolde));
    });
  }
}

final pendingSmsCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db.countPendingSms();
});
