import '../models/enum.dart';
import 'auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SmsEngineService {
  // Exemple pour Mvola : "Depot de 50000Ar effectue par 0340000000. Ref: 123456789"
  static Map<String, dynamic>? parseSms(String body, String sender) {
    final cleanBody = body.toLowerCase();

    // 1. Détection de l'opérateur selon l'expéditeur
    OperatorType? op;
    if (sender.contains('MVola') || sender.contains('TELMA'))
      op = OperatorType.telma;
    if (sender.contains('Orange')) op = OperatorType.orange;
    if (sender.contains('Airtel')) op = OperatorType.airtel;

    if (op == null) return null; // On ignore les SMS non officiels

    // 2. Extraction du montant (ex: 50.000 Ar ou 50000Ar)
    final amountRegex = RegExp(r'(\d+[\s.]?\d+)\s*(?:ar|ariary)');
    final amountMatch = amountRegex.firstMatch(cleanBody);
    final double? amount = amountMatch != null
        ? double.tryParse(
            amountMatch.group(1)!.replaceAll(RegExp(r'[\s.]'), ''),
          )
        : null;

    // 3. Extraction de la référence
    final refRegex = RegExp(r'(?:ref|transaction|n°)\s*:?\s*(\d+)');
    final refMatch = refRegex.firstMatch(cleanBody);
    final String? ref = refMatch?.group(1);

    if (amount == null || ref == null) return null;

    return {
      'operateur': op,
      'montant': amount,
      'reference': ref,
      'type': cleanBody.contains('depot')
          ? TransactionType.depot
          : TransactionType.retrait,
    };
  }
}
