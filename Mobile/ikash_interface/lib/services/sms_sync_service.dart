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
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    await db.transaction(() async {
      // 1. Chercher si une transaction avec cette référence existe déjà
      final existingTx = await (db.select(
        db.transactions,
      )..where((t) => t.reference.equals(sms.reference))).getSingleOrNull();

      if (existingTx != null) {
        // CAS 1 : Déjà saisie manuellement.
        // On ne change pas le solde (déjà fait à la saisie), on valide juste.
        print("Matching trouvé pour la référence ${sms.reference}");
      } else {
        // CAS 2 : Nouvelle transaction (SMS reçu avant saisie ou oubli)
        // ICI on applique l'impact sur le solde
        final impact = (sms.type == TransactionType.depot)
            ? -sms.montant
            : sms.montant;
        final nouveauSolde = (currentUser.soldeCourant + impact)
            .roundToDouble();

        // Insertion de la transaction "Automatique"
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                type: sms.type,
                montant: sms.montant,
                reference: sms.reference,
                operateur: sms.operateur,
                agentId: currentUser.id,
                estSaisieManuelle: const Value(
                  false,
                ), // Preuve que ça vient du SMS
                horodatage: Value(sms.dateReception),
              ),
            );

        // Mise à jour du solde seulement dans ce cas
        await (db.update(db.profiles)
              ..where((t) => t.id.equals(currentUser.id)))
            .write(ProfilesCompanion(soldeCourant: Value(nouveauSolde)));

        // Update UI state
        ref
            .read(currentUserProvider.notifier)
            .setUser(currentUser.copyWith(soldeCourant: nouveauSolde));
      }

      // 3. Dans tous les cas, le SMS est maintenant traité
      await (db.update(db.smsReceived)..where((t) => t.id.equals(sms.id)))
          .write(const SmsReceivedCompanion(estTraite: Value(true)));
    });
  }
}

final pendingSmsCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db.countPendingSms();
});
