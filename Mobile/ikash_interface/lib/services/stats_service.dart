import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'auth_service.dart';
import '../models/enum.dart';

final statsProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);

  // On écoute les transactions de la journée
  return db.select(db.transactions).watch().map((list) {
    double totalVolume = 0;
    int successCount = 0;

    for (var tx in list) {
      totalVolume += tx.montant;
      if (tx.statut == TransactionStatus.reussi) successCount++;
    }

    return {
      'volume': totalVolume,
      'count': list.length,
      'success': successCount,
    };
  });
});

final activityLogsProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  // On récupère les logs triés par date décroissante
  return (db.select(db.logActivities)..orderBy([
        (t) => OrderingTerm(expression: t.horodatage, mode: OrderingMode.desc),
      ]))
      .watch();
});
