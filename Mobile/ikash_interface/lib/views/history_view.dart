import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../providers/history_provider.dart';
import '../models/enum.dart';
import '../core/utils/formatters.dart'; // Import de l'utilitaire
import '../services/auth_service.dart';

class HistoryView extends ConsumerStatefulWidget {
  const HistoryView({super.key});

  @override
  ConsumerState<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<HistoryView> {
  String _searchQuery = "";
  String _selectedFilter = "Tous";
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(historyStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique"),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.calendar,
              color: _selectedDateRange != null ? theme.primaryColor : null,
            ),
            onPressed: () => _selectDateRange(context),
          ),
          if (_selectedDateRange != null)
            IconButton(
              icon: const Icon(LucideIcons.xCircle, size: 20),
              onPressed: () => setState(() => _selectedDateRange = null),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(theme),

          Expanded(
            child: historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Erreur : $err")),
              data: (allTransactions) {
                final filtered = _applyFilters(allTransactions);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.searchX,
                          size: 50,
                          color: theme.hintColor,
                        ),
                        const SizedBox(height: 10),
                        const Text("Aucune transaction trouvée"),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final tx = filtered[index];
                    return InkWell(
                      onTap: () => _showTransactionDetails(context, theme, tx),
                      borderRadius: BorderRadius.circular(16),
                      child: _buildTransactionCard(theme, tx),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- FILTRES ET RECHERCHE ---

  Widget _buildSearchAndFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: "Référence ou numéro client...",
              prefixIcon: const Icon(LucideIcons.search, size: 20),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
                0.3,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                "Tous",
                "TELMA",
                "ORANGE",
                "AIRTEL",
                "DEPOT",
                "RETRAIT",
              ].map((label) => _buildFilterChip(label, theme)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- DÉTAILS DE LA TRANSACTION ---

  void _showTransactionDetails(
    BuildContext context,
    ThemeData theme,
    Transaction tx,
  ) async {
    final db = ref.read(databaseProvider);
    final allPuces = await db.select(db.agentNumbers).get();

    final puceUtilisee = allPuces.firstWhere(
      (p) => p.id == tx.agentId,
      orElse: () => allPuces.first,
    );

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(LucideIcons.receipt),
            SizedBox(width: 10),
            Text("Détails"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPuceBadge(puceUtilisee, theme),
            const SizedBox(height: 20),
            _buildDetailRow("Référence", tx.reference, theme, isBold: true),
            _buildDetailRow("Client", tx.nomClient ?? "Inconnu", theme),
            _buildDetailRow("Contact", tx.numeroClient ?? "Aucun", theme),
            const Divider(height: 30),
            _buildDetailRow(
              "Montant Brut",
              CurrencyFormatter.format(tx.montant),
              theme,
              color: tx.type == TransactionType.retrait
                  ? Colors.green
                  : Colors.red,
              isBold: true,
            ),
            if (tx.bonus != null && tx.bonus! > 0)
              _buildDetailRow(
                "Frais/Bonus",
                CurrencyFormatter.format(tx.bonus!),
                theme,
              ),
            _buildDetailRow(
              "Date & Heure",
              DateFormat('dd/MM/yyyy à HH:mm').format(tx.horodatage),
              theme,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("FERMER"),
          ),
        ],
      ),
    );
  }

  // --- COMPOSANTS UI ---

  Widget _buildTransactionCard(ThemeData theme, Transaction tx) {
    final Color opColor = _getOpColor(tx.operateur);
    final bool isRetrait = tx.type == TransactionType.retrait;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: opColor.withOpacity(0.1),
            child: Text(
              tx.operateur.name[0].toUpperCase(),
              style: TextStyle(color: opColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (tx.nomClient != null && tx.nomClient!.isNotEmpty)
                      ? tx.nomClient!
                      : "Réf: ${tx.reference}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('dd MMM, HH:mm').format(tx.horodatage),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isRetrait ? '+' : '-'}${CurrencyFormatter.format(tx.montant)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isRetrait
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
              Text(
                tx.type.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildPuceBadge(AgentNumber puce, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _getOpColor(puce.operateur).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.smartphone,
            size: 16,
            color: _getOpColor(puce.operateur),
          ),
          const SizedBox(width: 8),
          Text(
            "${puce.operateur.name.toUpperCase()} (${puce.numeroPuce})",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    ThemeData theme, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ThemeData theme) {
    bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : null,
          ),
        ),
        selected: isSelected,
        selectedColor: theme.primaryColor,
        checkmarkColor: Colors.white,
        onSelected: (v) => setState(() => _selectedFilter = label),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) setState(() => _selectedDateRange = picked);
  }

  Color _getOpColor(OperatorType type) {
    switch (type) {
      case OperatorType.telma:
        return Colors.yellow.shade800;
      case OperatorType.orange:
        return Colors.orange.shade700;
      case OperatorType.airtel:
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  List<Transaction> _applyFilters(List<Transaction> txs) {
    return txs.where((tx) {
      final matchesSearch =
          tx.reference.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (tx.numeroClient?.contains(_searchQuery) ?? false) ||
          (tx.nomClient?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);

      bool matchesCategory =
          _selectedFilter == "Tous" ||
          tx.operateur.name.toUpperCase() == _selectedFilter ||
          tx.type.name.toUpperCase() == _selectedFilter;

      bool matchesDate = true;
      if (_selectedDateRange != null) {
        matchesDate =
            tx.horodatage.isAfter(_selectedDateRange!.start) &&
            tx.horodatage.isBefore(
              _selectedDateRange!.end.add(const Duration(days: 1)),
            );
      }
      return matchesSearch && matchesCategory && matchesDate;
    }).toList();
  }
}
