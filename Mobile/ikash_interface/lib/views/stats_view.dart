import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
//// Utilisation d'un alias pour éviter le conflit entre p.Context et BuildContext
//import 'package:path/path.dart' as p;
import '../database/app_database.dart';
import '../models/enum.dart';
import '../core/utils/formatters.dart';
import '../services/auth_service.dart';

class StatsView extends ConsumerWidget {
  const StatsView({super.key});

  // Logique de secours pour la détection de couleur par numéro
  Color _getColorFromNumber(String number) {
    if (number.startsWith('034') || number.startsWith('038'))
      return Colors.orange.shade700;
    if (number.startsWith('033')) return Colors.yellow.shade700;
    if (number.startsWith('032')) return Colors.red.shade700;
    return Colors.blueGrey;
  }

  // Détection de la couleur basée sur les puces configurées en DB
  Color _detectColorFromDB(List<AgentNumber> puces, OperatorType op) {
    try {
      final puce = puces.firstWhere((p) => p.operateur == op);
      return _getColorFromNumber(puce.numeroPuce);
    } catch (_) {
      return Colors.grey.shade400; // Couleur neutre si opérateur non configuré
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final db = ref.watch(databaseProvider);
    final pucesAsync = ref.watch(allPucesProvider);

    return pucesAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text("Erreur de configuration : $err"))),
      data: (puces) {
        final Map<OperatorType, Color> dynamicOpColors = {
          for (var op in OperatorType.values) op: _detectColorFromDB(puces, op),
        };

        return Scaffold(
          body: StreamBuilder<List<Transaction>>(
            stream: db.watchAllTransactions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final transactions = snapshot.data ?? [];
              final now = DateTime.now();

              // --- VARIABLES DE CALCUL ---
              double totalCommissionsMois = 0;
              double volumeEntrees = 0;
              double volumeSorties = 0;
              Map<OperatorType, double> opVolumes = {
                for (var v in OperatorType.values) v: 0,
              };
              Map<DateTime, double> dailyVolumes = {};
              Map<DateTime, double> dailyEntrees = {};
              Map<DateTime, double> dailySorties = {};

              // Initialisation des 7 derniers jours
              for (int i = 6; i >= 0; i--) {
                final date = DateTime(
                  now.year,
                  now.month,
                  now.day,
                ).subtract(Duration(days: i));
                dailyVolumes[date] = 0;
                dailyEntrees[date] = 0;
                dailySorties[date] = 0;
              }

              for (var tx in transactions) {
                // Calculs mensuels
                if (tx.horodatage.month == now.month &&
                    tx.horodatage.year == now.year) {
                  totalCommissionsMois += tx.bonus ?? 0;
                  if (tx.type == TransactionType.depot ||
                      tx.type == TransactionType.transfert) {
                    volumeEntrees += tx.montant;
                  } else {
                    volumeSorties += tx.montant;
                  }
                  opVolumes[tx.operateur] =
                      (opVolumes[tx.operateur] ?? 0) + tx.montant;
                }

                // Calculs journaliers (7 jours)
                final txDate = DateTime(
                  tx.horodatage.year,
                  tx.horodatage.month,
                  tx.horodatage.day,
                );
                if (dailyVolumes.containsKey(txDate)) {
                  dailyVolumes[txDate] = dailyVolumes[txDate]! + tx.montant;
                  if (tx.type == TransactionType.depot ||
                      tx.type == TransactionType.transfert) {
                    dailyEntrees[txDate] = dailyEntrees[txDate]! + tx.montant;
                  } else {
                    dailySorties[txDate] = dailySorties[txDate]! + tx.montant;
                  }
                }
              }

              // --- PRÉPARATION DES DONNÉES GRAPHES ---
              final dates = dailyVolumes.keys.toList();
              final List<FlSpot> volumeSpots = List.generate(dates.length, (i) {
                return FlSpot(i.toDouble(), dailyVolumes[dates[i]]! / 1000);
              });

              final List<BarChartGroupData> barGroups = List.generate(
                dates.length,
                (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: dailyEntrees[dates[i]]! / 1000,
                        color: Colors.blue.shade400,
                        width: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: dailySorties[dates[i]]! / 1000,
                        color: Colors.purple.shade400,
                        width: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                },
              );

              return CustomScrollView(
                slivers: [
                  _buildAppBar(theme),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildQuickSummary(
                            theme,
                            volumeEntrees,
                            volumeSorties,
                          ),
                          const SizedBox(height: 15),
                          _buildHeroCommissionCard(
                            theme,
                            isDark,
                            totalCommissionsMois,
                          ),
                          const SizedBox(height: 25),
                          _buildSectionTitle(
                            theme,
                            "Activité (en milliers Ar)",
                            LucideIcons.activity,
                          ),
                          const SizedBox(height: 15),
                          _buildLineChart(
                            context,
                            theme,
                            volumeSpots,
                            dates,
                            transactions,
                          ),
                          const SizedBox(height: 25),
                          _buildSectionTitle(
                            theme,
                            "Flux Entrées/Sorties",
                            LucideIcons.barChart3,
                          ),
                          const SizedBox(height: 15),
                          _buildHistogramChart(
                            context,
                            theme,
                            barGroups,
                            dates,
                            transactions,
                          ),
                          const SizedBox(height: 25),
                          _buildSectionTitle(
                            theme,
                            "Performance Opérateurs",
                            LucideIcons.layers,
                          ),
                          const SizedBox(height: 15),
                          _buildOperatorSection(
                            theme,
                            opVolumes,
                            dynamicOpColors,
                            (volumeEntrees + volumeSorties),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // --- WIDGETS COMPOSANTS ---

  Widget _buildQuickSummary(ThemeData theme, double inVol, double outVol) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniStat(theme, "Flux Entrant", inVol, Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniStat(theme, "Flux Sortant", outVol, Colors.purple),
        ),
      ],
    );
  }

  Widget _buildMiniStat(
    ThemeData theme,
    String title,
    double val,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              CurrencyFormatter.format(val),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: color,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(
    BuildContext context,
    ThemeData theme,
    List<FlSpot> spots,
    List<DateTime> dates,
    List<Transaction> transactions,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 20, 15, 5),
      decoration: _cardDecoration(theme),
      child: AspectRatio(
        aspectRatio: 1.8,
        child: LineChart(
          LineChartData(
            clipData: const FlClipData.all(),
            lineTouchData: LineTouchData(
              touchCallback:
                  (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    if (event is FlTapUpEvent &&
                        touchResponse != null &&
                        touchResponse.lineBarSpots != null) {
                      final index = touchResponse.lineBarSpots!.first.x.toInt();
                      _showTransactionsDetail(
                        context,
                        transactions,
                        dates[index],
                        theme,
                      );
                    }
                  },
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) => touchedSpots
                    .map(
                      (s) => LineTooltipItem(
                        "${CurrencyFormatter.format(s.y * 1000)} Ar",
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 500,
              getDrawingHorizontalLine: (value) => FlLine(
                color: theme.dividerColor.withOpacity(0.1),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (v, m) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      "${v.toInt()}k",
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, m) {
                    if (v % 2 != 0 || v.toInt() >= dates.length)
                      return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        DateFormat('dd/MM').format(dates[v.toInt()]),
                        style: const TextStyle(fontSize: 9),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.35,
                color: theme.primaryColor,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: theme.primaryColor.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistogramChart(
    BuildContext context,
    ThemeData theme,
    List<BarChartGroupData> groups,
    List<DateTime> dates,
    List<Transaction> transactions,
  ) {
    double maxVal = 0;
    for (var g in groups) {
      for (var r in g.barRods) {
        if (r.toY > maxVal) maxVal = r.toY;
      }
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(theme),
      child: AspectRatio(
        aspectRatio: 1.8,
        child: BarChart(
          BarChartData(
            maxY: maxVal * 1.2,
            barGroups: groups,
            barTouchData: BarTouchData(
              touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                if (event is FlTapUpEvent &&
                    response != null &&
                    response.spot != null) {
                  final index = response.spot!.touchedBarGroupIndex;
                  _showTransactionsDetail(
                    context,
                    transactions,
                    dates[index],
                    theme,
                  );
                }
              },
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                    BarTooltipItem(
                      "${CurrencyFormatter.format(rod.toY * 1000)} Ar",
                      TextStyle(
                        color: rod.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, m) {
                    if (v.toInt() >= dates.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('dd/MM').format(dates[v.toInt()]),
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionsDetail(
    BuildContext context,
    List<Transaction> transactions,
    DateTime date,
    ThemeData theme,
  ) {
    final dailyTxs = transactions
        .where(
          (tx) =>
              tx.horodatage.year == date.year &&
              tx.horodatage.month == date.month &&
              tx.horodatage.day == date.day,
        )
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              DateFormat('EEEE dd MMMM', 'fr_FR').format(date).toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: dailyTxs.isEmpty
                  ? const Center(child: Text("Aucune transaction ce jour"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: dailyTxs.length,
                      itemBuilder: (context, index) {
                        final tx = dailyTxs[index];
                        final isEntry =
                            tx.type == TransactionType.depot ||
                            tx.type == TransactionType.transfert;
                        return Card(
                          elevation: 0,
                          color: theme.cardColor,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  (isEntry ? Colors.blue : Colors.purple)
                                      .withOpacity(0.1),
                              child: Icon(
                                isEntry
                                    ? LucideIcons.arrowDownLeft
                                    : LucideIcons.arrowUpRight,
                                color: isEntry ? Colors.blue : Colors.purple,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              tx.reference ?? "Sans référence",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat('HH:mm').format(tx.horodatage),
                            ),
                            trailing: Text(
                              CurrencyFormatter.format(tx.montant),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: isEntry ? Colors.blue : Colors.purple,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorSection(
    ThemeData theme,
    Map<OperatorType, double> volumes,
    Map<OperatorType, Color> colors,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(theme),
      child: Column(
        children: OperatorType.values.map((op) {
          final share = total > 0 ? (volumes[op] ?? 0) / total : 0.0;
          final color = colors[op] ?? Colors.grey;
          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      op.name.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${(share * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: share,
                  backgroundColor: color.withOpacity(0.1),
                  color: color,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          );
        }).toList(),
      ),
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
            isDark ? Colors.blue.shade800 : Colors.lightBlue.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Mes commissions (ce mois)",
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.sparkles, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text(
                  "En progression",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 80,
      pinned: true,
      centerTitle: true,
      title: const Text(
        "Statistiques Globales",
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration(ThemeData theme) {
    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
