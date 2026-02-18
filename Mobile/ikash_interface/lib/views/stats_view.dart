import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../database/app_database.dart';
import '../models/enum.dart';
import '../core/utils/formatters.dart';
import '../services/auth_service.dart';

class StatsView extends ConsumerWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final db = ref.watch(databaseProvider);

    return Scaffold(
      body: StreamBuilder<List<Transaction>>(
        stream: db.watchAllTransactions(), // On écoute toutes les transactions
        builder: (context, snapshot) {
          final transactions = snapshot.data ?? [];

          // --- LOGIQUE DE CALCUL DYNAMIQUE ---
          final now = DateTime.now();
          double totalCommissionsMois = 0;
          double volumeDepots = 0;
          double volumeRetraits = 0;

          // Map pour la répartition par opérateur
          Map<OperatorType, double> opVolumes = {
            OperatorType.telma: 0,
            OperatorType.orange: 0,
            OperatorType.airtel: 0,
          };

          for (var tx in transactions) {
            // Filtrer sur le mois actuel uniquement
            if (tx.horodatage.month == now.month &&
                tx.horodatage.year == now.year) {
              totalCommissionsMois += tx.bonus ?? 0;

              if (tx.type == TransactionType.depot ||
                  tx.type == TransactionType.transfert) {
                volumeDepots += tx.montant;
              } else if (tx.type == TransactionType.retrait) {
                volumeRetraits += tx.montant;
              }

              // Cumul par opérateur pour la barre de progression
              opVolumes[tx.operateur] =
                  (opVolumes[tx.operateur] ?? 0) + tx.montant;
            }
          }

          double totalVolumeMois = volumeDepots + volumeRetraits;

          return CustomScrollView(
            slivers: [
              _buildAppBar(theme),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // --- Carte Commission Dynamique ---
                      _buildHeroCommissionCard(
                        theme,
                        isDark,
                        totalCommissionsMois,
                      ),

                      const SizedBox(height: 15),
                      // --- Grille de Volumes ---
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1.3,
                        children: [
                          _buildStatCard(
                            theme,
                            "Volume Sorties",
                            CurrencyFormatter.format(volumeDepots),
                            LucideIcons.trendingUp,
                            Colors.green.shade400,
                          ),
                          _buildStatCard(
                            theme,
                            "Volume Entrées",
                            CurrencyFormatter.format(volumeRetraits),
                            LucideIcons.trendingDown,
                            Colors.orange.shade400,
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // --- Répartition par Opérateur ---
                      _buildOperatorSection(
                        theme,
                        isDark,
                        opVolumes,
                        totalVolumeMois,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- COMPOSANTS DE L'INTERFACE ---

  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          "Mes Gains & Stats",
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
    );
  }

  Widget _buildHeroCommissionCard(ThemeData theme, bool isDark, double amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            isDark ? Colors.green.shade800 : Colors.greenAccent.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            "Commissions cumulées ce mois",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStat(
                "Performance",
                amount > 50000 ? "Excellente" : "Stable",
              ),
              _buildQuickStat(
                "Bonus Estimé",
                CurrencyFormatter.format(amount * 0.1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorSection(
    ThemeData theme,
    bool isDark,
    Map<OperatorType, double> volumes,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? theme.dividerColor.withOpacity(0.1)
              : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Répartition par Opérateur",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...OperatorType.values.map((op) {
            double share = total > 0 ? (volumes[op] ?? 0) / total : 0;
            return _buildOperatorProgress(
              theme,
              op.name.toUpperCase(),
              share,
              _getOpColor(op),
            );
          }),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Color _getOpColor(OperatorType type) {
    if (type == OperatorType.telma) return Colors.orange.shade700;
    if (type == OperatorType.orange) return Colors.orange;
    return Colors.red;
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(title, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildOperatorProgress(
    ThemeData theme,
    String label,
    double percent,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "${(percent * 100).toInt()}%",
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: color.withOpacity(0.1),
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}
