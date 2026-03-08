import '../models/enum.dart';

class SmsEngineService {
  static Map<String, dynamic>? parseSms(String body, String sender) {
    // Nettoyage pour éviter les problèmes de sauts de ligne et espaces doubles
    final cleanBody = body.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    // 1. Identification stricte de l'opérateur
    OperatorType? op;
    final senderUpper = sender.toUpperCase();
    if (sender == '807' || senderUpper == 'MVola' || senderUpper == 'TELMA') {
      op = OperatorType.telma;
    } else if (senderUpper.contains('ORANGE')) {
      op = OperatorType.orange;
    } else if (senderUpper.contains('AIRTEL')) {
      op = OperatorType.airtel;
    }

    if (op == null) return null;

    // --- SÉCURITÉ : ÉCHECS ---
    if (cleanBody.contains('echec') ||
        cleanBody.contains('annul') ||
        cleanBody.contains('insuffisant')) {
      return null;
    }

    // 2. EXTRACTION DU MONTANT
    // On cherche un nombre précédé ou suivi de "ar", sans prendre les dates ou ID
    //  regarde si "ar" est collé ou proche (ex: Ar20000 ou 20 000 Ar)
    final amountRegex = RegExp(
      r'(?:ar\s?|montant\s?:?\s?)([\d\s\.,]{3,})|([\d\s\.,]{3,})\s?ar',
      caseSensitive: false,
    );

    final amountMatch = amountRegex.firstMatch(cleanBody);
    if (amountMatch == null) return null;

    // On récupère le groupe qui a matché (soit avant Ar, soit après Ar)
    String rawAmount = (amountMatch.group(1) ?? amountMatch.group(2) ?? "")
        .replaceAll(RegExp(r'[^\d]'), '');

    // CAS SPÉCIAL : Si le montant capturé est une partie de l'ID (trop long), on limite
    if (rawAmount.length > 9) return null;

    final double amount = double.tryParse(rawAmount) ?? 0;
    if (amount == 0) return null;

    // 3. EXTRACTION DE LA RÉFÉRENCE (ID)
    // On gère les formats "ID:CI...", "Ref: 878...", "Ref:878..."
    final refRegex = RegExp(
      r'(?:id|ref|n°|transaction)\s?:?\s*([a-z0-9\.]+)',
      caseSensitive: false,
    );
    final refMatch = refRegex.firstMatch(cleanBody);
    final String? ref = refMatch?.group(1)?.toUpperCase();

    if (ref == null) return null;

    // 4. DÉTECTION DU TYPE (Logique de flux d'argent pour l'Agent)
    TransactionType type;

    // ENTRÉE D'ARGENT (Retrait pour le client, l'agent reçoit)
    if (cleanBody.contains('recu de') ||
        cleanBody.contains('reçu de') ||
        cleanBody.contains('credite de') || // "Vous avez credite... de X Ar" (Souvent Airtel/Orange)
        cleanBody.contains('approvisionnement')) {
      type = TransactionType.retrait;
    }
    // SORTIE D'ARGENT (Dépôt pour le client, l'agent envoie)
    else if (cleanBody.contains('depot de') ||
             cleanBody.contains('dépot de') ||
             cleanBody.contains('envoye a') ||
             cleanBody.contains('envoyé à') ||
             cleanBody.contains('transfert de')) {
      type = TransactionType.depot;
    } else {
      // Si ambigu, on ne prend pas de risque
      return null;
    }

    return {
      'operateur': op,
      'montant': amount,
      'reference': ref,
      'type': type,
      'rawBody': body,
    };
  }
}
