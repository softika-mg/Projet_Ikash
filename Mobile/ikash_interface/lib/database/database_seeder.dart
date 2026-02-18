import 'package:drift/drift.dart';
import 'app_database.dart'; // Assurez-vous que le chemin est bon
import '../models/enum.dart'; // Pour OperatorType

extension DatabaseSeeder on AppDatabase {
  Future<void> seedTarifsInitiaux() async {
    // On vérifie d'abord si la table est vide pour ne pas créer de doublons
    final count = (await select(tarifs).get()).length;
    if (count > 0) return;

    // J'utilise batch pour insérer tout d'un coup (plus rapide)
    await batch((batch) {
      // Je définis une liste de données basées sur votre PHOTO
      // Note: J'ai comblé les trous entre les tranches (ex: 25k-30k)
      final List<TarifsCompanion> listeTarifs = [
        // 0 à 5 000
        TarifsCompanion.insert(
          operateur: OperatorType
              .telma, // On pourra dupliquer pour Orange/Airtel après
          montantMin: 0,
          montantMax: 5000,
          fraisOperateur: 200,
          fraisClient: 700, // Gain: 500
        ),
        // 5 000 à 10 000
        TarifsCompanion.insert(
          operateur: OperatorType.telma,
          montantMin: 5001,
          montantMax: 10000,
          fraisOperateur: 300,
          fraisClient: 1000, // Gain: 700
        ),
        // 10 000 à 25 000 (Correction stylo prise en compte : 1500)
        TarifsCompanion.insert(
          operateur: OperatorType.telma,
          montantMin: 10001,
          montantMax: 25000,
          fraisOperateur: 650,
          fraisClient: 1500, // Gain: 850
        ),
        // 25 000 à 50 000 (J'ai fusionné pour couvrir le trou 25-30k)
        TarifsCompanion.insert(
          operateur: OperatorType.telma,
          montantMin: 25001,
          montantMax: 50000,
          fraisOperateur: 1300,
          fraisClient: 3000, // J'ai pris la valeur basse (3000) vs 3500
        ),
        // 50 000 à 80 000 (J'ai fusionné pour couvrir le trou 50-60k)
        TarifsCompanion.insert(
          operateur: OperatorType.telma,
          montantMin: 50001,
          montantMax: 80000,
          fraisOperateur: 1900,
          fraisClient: 4000,
        ),
        // 80 000 à 100 000 (Attention ici, la photo indique 90-100, j'ai élargi)
        TarifsCompanion.insert(
          operateur: OperatorType.telma,
          montantMin: 80001,
          montantMax: 100000,
          fraisOperateur: 1900, // Gardé le même frais que tranche précédente ?
          fraisClient: 4500, // Valeur basse de "4500/6000"
        ),
        // 100 000 à 250 000
        TarifsCompanion.insert(
          operateur: OperatorType.telma,
          montantMin: 100001,
          montantMax: 250000,
          fraisOperateur: 3400,
          fraisClient: 7000,
        ),
        // 250 000 à 600 000
        TarifsCompanion.insert(
          operateur: OperatorType.telma,
          montantMin: 250001,
          montantMax: 600000,
          fraisOperateur: 4700,
          fraisClient: 10000,
        ),
        // 600 000 à 1 000 000
        TarifsCompanion.insert(
          operateur: OperatorType.telma,
          montantMin: 600001,
          montantMax: 1000000,
          fraisOperateur: 8800,
          fraisClient: 18000,
        ),
        // 1 000 000 à 2 000 000
        TarifsCompanion.insert(
          operateur: OperatorType.telma,
          montantMin: 1000001,
          montantMax: 2000000,
          fraisOperateur: 14700,
          fraisClient: 30000,
        ),
        // Plus de 2 000 000
        TarifsCompanion.insert(
          operateur: OperatorType.telma,
          montantMin: 2000001,
          montantMax: 100000000, // Un très grand nombre
          fraisOperateur: 19600,
          fraisClient: 42000,
        ),
      ];

      batch.insertAll(tarifs, listeTarifs);
    });
  }
}
