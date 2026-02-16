import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../core/utils/formatters.dart';
import '../services/auth_service.dart';

class AdminLogsView extends ConsumerWidget {
  const AdminLogsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Flux d'activités"),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<List<Transaction>>(
        // On récupère les 50 dernières transactions pour le flux
        stream: db.watchAllTransactions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data!;

          if (transactions.isEmpty) {
            return const Center(child: Text("Aucune activité récente"));
          }

          return ListView.builder(
            itemCount: transactions.length,
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemBuilder: (context, index) {
              final tx = transactions[index];

              // Déduction d'un "état d'erreur" (exemple : bonus nul ou montant suspect)
              final bool isWarning = tx.bonus == 0 && tx.montant > 0;

              return _buildLogTile(
                theme: theme,
                // On affiche l'opérateur comme "Agent/Source"
                source: tx.operateur.name.toUpperCase(),
                action: "${tx.type.name.toUpperCase()} validé",
                time: _formatTimestamp(tx.horodatage),
                status: isWarning ? "Vérification" : "Succès",
                message: "Réf: ${tx.reference} | ${CurrencyFormatter.format(tx.montant)}",
                isWarning: isWarning,
                isLast: index == transactions.length - 1,
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return "Il y a ${difference.inMinutes} min";
    } else if (difference.inHours < 24) {
      return "Il y a ${difference.inHours} h";
    } else {
      return DateFormat('dd MMM, HH:mm', 'fr_FR').format(date);
    }
  }

  Widget _buildLogTile({
    required ThemeData theme,
    required String source,
    required String action,
    required String time,
    required String status,
    required String message,
    required bool isWarning,
    bool isLast = false,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Timeline ---
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isWarning ? Colors.orange : Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? theme.scaffoldBackgroundColor : Colors.white,
                    width: 2,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 70,
                  color: theme.dividerColor.withOpacity(0.1),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // --- Contenu ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      source,
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(time, style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  action,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isWarning ? Colors.orange : theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
