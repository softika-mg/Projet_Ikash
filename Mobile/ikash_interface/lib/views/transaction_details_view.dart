import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Nécessaire pour copier dans le presse-papier
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../database/app_database.dart';
import '../core/utils/formatters.dart';

class TransactionDetailView extends StatelessWidget {
  final Transaction transaction;
  final Color operatorColor;

  const TransactionDetailView({
    super.key,
    required this.transaction,
    required this.operatorColor,
  });

  // Petite fonction pour copier la référence avec un retour humain
  void _copierReference(BuildContext context, String reference) {
    Clipboard.setData(ClipboardData(text: reference));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(LucideIcons.smile, color: Colors.white),
            SizedBox(width: 12),
            Text("Référence copiée ! Prêt à être collée."),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isRetrait = transaction.type.name == 'retrait';

    // On adapte le texte selon l'action pour que ça ait l'air naturel
    final String actionText = isRetrait ? "Retrait d'argent" : "Dépôt d'argent";
    final String clientLabel = isRetrait ? "Retiré par" : "Envoyé à";

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? Colors.black
          : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Détails de l'opération"),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- LE TICKET DE CAISSE REVISITÉ ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // En-tête : Plus expressif et festif
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: operatorColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: operatorColor,
                          child: Icon(
                            isRetrait
                                ? LucideIcons.arrowDownToLine
                                : LucideIcons.send,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Super ! L'opération a réussi ",
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${isRetrait ? '+' : '-'}${CurrencyFormatter.format(transaction.montant)}",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: isRetrait
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: operatorColor,
                            borderRadius: BorderRadius.circular(
                              20,
                            ), // Plus arrondi
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.radioTower,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                transaction.operateur.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Corps du ticket : Des phrases humaines avec des icônes
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildHumanDetailItem(
                          icon: LucideIcons.activity,
                          label: "Ce que vous avez fait",
                          value: actionText,
                          isBold: true,
                        ),
                        const Divider(height: 32),

                        // Ligne Référence avec bouton de copie interactif
                        _buildHumanDetailItem(
                          icon: LucideIcons.hash,
                          label: "Numéro de référence",
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                transaction.reference,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _copierReference(
                                  context,
                                  transaction.reference,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    LucideIcons.copy,
                                    size: 16,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 32),

                        _buildHumanDetailItem(
                          icon: LucideIcons.userCheck,
                          label: clientLabel,
                          value: transaction.nomClient?.isNotEmpty == true
                              ? transaction.nomClient!
                              : "Un client anonyme",
                        ),
                        const SizedBox(height: 16),

                        _buildHumanDetailItem(
                          icon: LucideIcons.phone,
                          label: "Sur le numéro",
                          value: transaction.numeroClient?.isNotEmpty == true
                              ? transaction.numeroClient!
                              : "Non renseigné",
                        ),
                        const Divider(height: 32),

                        _buildHumanDetailItem(
                          icon: LucideIcons.calendarClock,
                          label: "Quand ça s'est passé ?",
                          value: DateFormat("'Le' dd MMMM yyyy 'à' HH:mm")
                              .format(
                                transaction.horodatage,
                              ), // Format plus humain
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Un bouton amical pour fermer ou faire une autre action
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.thumbsUp),
                label: const Text(
                  "Génial, retour à l'historique !",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: operatorColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper interne repensé pour inclure une icône et être plus aéré
  Widget _buildHumanDetailItem({
    required IconData icon,
    required String label,
    String? value,
    Widget? child,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade400),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(width: 16),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child:
                child ??
                Text(
                  value ?? '',
                  style: TextStyle(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.end,
                ),
          ),
        ),
      ],
    );
  }
}
