import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../database/app_database.dart';
import '../models/enum.dart';
import '../core/utils/formatters.dart';
import '../services/auth_service.dart';


class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.grey.shade50,
      body: StreamBuilder<List<Transaction>>(
        stream: db.watchAllTransactions(),
        builder: (context, snapshot) {
          final transactions = snapshot.data ?? [];

          // --- LOGIQUE DE CALCUL PAR PUCE ---
          double volumeTotal = 0;
          Map<OperatorType, double> volumeParPuce = {
            OperatorType.telma: 0,
            OperatorType.orange: 0,
            OperatorType.airtel: 0,
          };
          Map<OperatorType, int> nombreOpsParPuce = {
            OperatorType.telma: 0,
            OperatorType.orange: 0,
            OperatorType.airtel: 0,
          };

          for (var tx in transactions) {
            volumeTotal += tx.montant;
            volumeParPuce[tx.operateur] = (volumeParPuce[tx.operateur] ?? 0) + tx.montant;
            nombreOpsParPuce[tx.operateur] = (nombreOpsParPuce[tx.operateur] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Performance des Puces",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // --- Cartes de Performance Globales ---
                Row(
                  children: [
                    _buildSummaryCard(
                      title: "Volume Global",
                      value: CurrencyFormatter.format(volumeTotal),
                      icon: LucideIcons.barChart3,
                      color: isDark ? Colors.indigo.shade400 : Colors.indigo,
                    ),
                    const SizedBox(width: 15),
                    _buildSummaryCard(
                      title: "Puces Actives",
                      value: "3 / 3",
                      icon: LucideIcons.smartphone, // Icone plus adaptée
                      color: isDark ? Colors.teal.shade600 : Colors.teal,
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // --- Section Classement des Puces ---
                Text(
                  "Activité par SIM",
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // On génère dynamiquement les cartes pour chaque opérateur
                ...OperatorType.values.map((op) => _buildSimRankCard(
                  theme,
                  op.name.toUpperCase(),
                  CurrencyFormatter.format(volumeParPuce[op] ?? 0),
                  "${nombreOpsParPuce[op]} opérations",
                  _getOpColor(op),
                )),

                const SizedBox(height: 30),

                // --- Répartition Visuelle ---
                _buildDistributionSection(theme, isDark, volumeParPuce, volumeTotal),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- COMPOSANTS UI ---

  Widget _buildSimRankCard(ThemeData theme, String name, String volume, String desc, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.smartphone, size: 20, color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(desc, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            volume,
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionSection(ThemeData theme, bool isDark, Map<OperatorType, double> volumes, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Répartition du Volume", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...OperatorType.values.map((op) {
            double percent = total > 0 ? (volumes[op] ?? 0) / total : 0;
            return _buildAdminProgress(theme, op.name.toUpperCase(), percent, _getOpColor(op));
          }),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Color _getOpColor(OperatorType type) {
  switch (type) {
    case OperatorType.telma:
      return Colors.yellow.shade800;
    case OperatorType.orange:
      return Colors.orange;
    case OperatorType.airtel:
      return Colors.red;
    case OperatorType.autre: // Ajout du cas manquant
      return Colors.grey;
  }
}

  Widget _buildSummaryCard({required String title, required String value, required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 15),
            FittedBox(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminProgress(ThemeData theme, String label, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text("${(percent * 100).toInt()}%", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: color.withOpacity(0.1),
            color: color,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}
