import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../core/utils/formatters.dart';
import "log_details_view.dart";
import '../services/auth_service.dart';

class AdminLogsView extends ConsumerWidget {
  const AdminLogsView({super.key});

  // --- Utilitaire pour convertir le String Hexa en Color (identique au dashboard) ---
  Color _getParsedColor(String? dbColor) {
    if (dbColor == null || dbColor.isEmpty) return Colors.blueGrey;
    try {
      if (dbColor.contains('#')) {
        return Color(int.parse(dbColor.replaceAll('#', 'FF'), radix: 16));
      }
      return Color(int.parse(dbColor));
    } catch (e) {
      return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);

    // On récupère les puces pour avoir accès à leurs couleurs
    final pucesAsync = ref.watch(allPucesProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Vérification des Flux", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: pucesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Erreur : $err")),
        data: (listePuces) {
          return StreamBuilder<List<Transaction>>(
            stream: db.watchAllTransactions(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              final transactions = snapshot.data!;
              if (transactions.isEmpty) return const Center(child: Text("Aucune activité"));

              return StreamBuilder<List<SmsReceivedData>>(
                stream: db.watchAllSms(),
                builder: (context, smsSnapshot) {
                  final allSms = smsSnapshot.data ?? [];

                  return ListView.builder(
                    itemCount: transactions.length,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemBuilder: (context, index) {
                      final tx = transactions[index];

                      // 1. Trouver la puce correspondante pour obtenir la couleur
                      final puceAssociee = listePuces.cast<AgentNumber?>().firstWhere(
                        (p) => p?.operateur == tx.operateur,
                        orElse: () => null,
                      );

                      final Color opColor = _getParsedColor(puceAssociee?.color);

                      // 2. Trouver le SMS correspondant
                      final matchingSms = allSms.cast<SmsReceivedData?>().firstWhere(
                        (s) => s?.reference == tx.reference,
                        orElse: () => null,
                      );

                      return _buildEnhancedLogTile(
                        context: context,
                        theme: theme,
                        tx: tx,
                        sms: matchingSms,
                        opColor: opColor,
                        isLast: index == transactions.length - 1,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEnhancedLogTile({
    required BuildContext context,
    required ThemeData theme,
    required Transaction tx,
    required SmsReceivedData? sms,
    required Color opColor, // Nouvelle propriété
    bool isLast = false,
  }) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (sms == null) {
      statusColor = Colors.orange;
      statusText = "En attente SMS";
      statusIcon = LucideIcons.clock;
    } else if (sms.montant == tx.montant) {
      statusColor = Colors.green;
      statusText = "Confirmé";
      statusIcon = LucideIcons.checkCircle2;
    } else {
      statusColor = Colors.red;
      statusText = "Incohérence";
      statusIcon = LucideIcons.alertTriangle;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LogDetailView(transaction: tx, sms: sms, opColor: opColor,),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline colorée selon le statut
            Column(
              children: [
                Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                  child: Icon(statusIcon, size: 10, color: Colors.white),
                ),
                if (!isLast)
                  Container(width: 2, height: 90, color: theme.dividerColor.withOpacity(0.1)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tx.operateur.name.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, color: opColor)), // Couleur Opérateur
                      Text(_formatTimestamp(tx.horodatage), style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      // Bordure utilisant la couleur de la PUCE
                      border: Border.all(color: opColor.withOpacity(0.3), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: opColor.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Réf: ${tx.reference}", style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(CurrencyFormatter.format(tx.montant),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                            Icon(LucideIcons.chevronRight, size: 14, color: theme.dividerColor),
                          ],
                        ),
                        if (sms != null && sms.montant != tx.montant)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text("⚠️ SMS indique: ${CurrencyFormatter.format(sms.montant)}",
                                style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 60) return "Il y a ${difference.inMinutes} min";
    if (difference.inHours < 24) return "Il y a ${difference.inHours} h";
    return DateFormat('dd MMM, HH:mm', 'fr').format(date);
  }
}
