import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../database/app_database.dart';
import '../models/enum.dart';
import '../core/utils/formatters.dart';
import '../services/auth_service.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  // --- CONVERTISSEUR DE COULEUR DB -> FLUTTER ---
  Color _getParsedColor(String? dbColor) {
    if (dbColor == null || dbColor.isEmpty) return Colors.blueGrey;

    // Si tu as enregistré via color.value.toString(), c'est un grand entier
    // Si c'est un format Hexa (#FF...), on le traite aussi
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
    final isDark = theme.brightness == Brightness.dark;
    final db = ref.watch(databaseProvider);
    final pucesAsync = ref.watch(allPucesProvider);

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Tableau de Bord Admin", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: pucesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Erreur : $err")),
        data: (listePuces) {
          if (listePuces.isEmpty) {
            return const Center(child: Text("Aucune puce configurée."));
          }

          return StreamBuilder<List<Transaction>>(
            stream: db.watchAllTransactions(),
            builder: (context, snapshot) {
              final transactions = snapshot.data ?? [];

              // --- CALCULS ---
              double volumeTotal = 0;
              final Map<OperatorType, double> volumeParPuce = {};
              for (var p in listePuces) { volumeParPuce[p.operateur] = 0.0; }

              for (var tx in transactions) {
                volumeTotal += tx.montant;
                if (volumeParPuce.containsKey(tx.operateur)) {
                  volumeParPuce[tx.operateur] = (volumeParPuce[tx.operateur] ?? 0) + tx.montant;
                }
              }

              return RefreshIndicator(
                onRefresh: () async => ref.refresh(allPucesProvider),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- RÉSUMÉ ---
                      Row(
                        children: [
                          _buildSummaryCard(
                            title: "Volume Global",
                            value: CurrencyFormatter.format(volumeTotal),
                            icon: LucideIcons.trendingUp,
                            color: isDark ? Colors.indigo.shade400 : Colors.indigo.shade700,
                          ),
                          const SizedBox(width: 15),
                          _buildSummaryCard(
                            title: "SIMs Actives",
                            value: "${listePuces.length}",
                            icon: LucideIcons.smartphone,
                            color: isDark ? Colors.teal.shade600 : Colors.teal.shade700,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      _buildSectionHeader(theme, "État des Puces (SIM)", LucideIcons.layers),
                      const SizedBox(height: 15),

                      // --- LISTE DES SIMS AVEC SOLDE ---
                      ...listePuces.map((puce) {
                        final color = _getParsedColor(puce.color);
                        final volume = volumeParPuce[puce.operateur] ?? 0;

                        return _buildEnhancedSimCard(
                          theme: theme,
                          label: puce.numeroPuce,
                          subLabel: puce.operateur.name.toUpperCase(),
                          volume: volume,
                          solde: puce.soldePuce, // Utilisation du solde de ta table AgentNumbers
                          color: color,
                        );
                      }),

                      const SizedBox(height: 30),

                      // --- RÉPARTITION ---
                      _buildDistributionSection(theme, listePuces, volumeParPuce, volumeTotal),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- CARTE SIM AMÉLIORÉE (Avec Solde et Volume) ---
  Widget _buildEnhancedSimCard({
    required ThemeData theme,
    required String label,
    required String subLabel,
    required double volume,
    required double solde,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(LucideIcons.phone, size: 16, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(subLabel, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(CurrencyFormatter.format(solde),
                    style: TextStyle(fontWeight: FontWeight.w900, color: color)),
                  const Text("Solde actuel", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Volume traité", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              Text(CurrencyFormatter.format(volume),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  // --- AUTRES COMPOSANTS ---
  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: 10),
        Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDistributionSection(ThemeData theme, List<AgentNumber> puces, Map<OperatorType, double> volumes, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Parts de marché (Volume)", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (total == 0) const Center(child: Text("Aucun volume"))
          else ...puces.map((p) {
            double percent = (volumes[p.operateur] ?? 0) / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p.numeroPuce, style: const TextStyle(fontSize: 12)),
                      Text("${(percent * 100).toInt()}%", style: TextStyle(color: _getParsedColor(p.color), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: percent,
                    backgroundColor: _getParsedColor(p.color).withOpacity(0.1),
                    color: _getParsedColor(p.color),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
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
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 15),
            FittedBox(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
