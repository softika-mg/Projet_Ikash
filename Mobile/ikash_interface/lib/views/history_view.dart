import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikash_interface/providers/agent_number_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../models/enum.dart';
import '../core/utils/formatters.dart';
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

  // --- LOGIQUE DE COULEUR (Identique à AgentHome pour la cohérence) ---
  Color _getTransactionColor(Transaction tx, List<AgentNumber> puces) {
    try {
      // On cherche dans la liste des puces celle qui a le même OperatorType
      // p.operateur est l'énumération car tu utilises intEnum<OperatorType>() dans ta table
      final puceIdoine = puces.firstWhere((p) => p.operateur == tx.operateur);

      // Si on trouve une puce pour cet opérateur avec une couleur définie
      if (puceIdoine.color != null && puceIdoine.color!.isNotEmpty) {
        return Color(int.parse(puceIdoine.color!));
      }
    } catch (e) {
      // Si aucune puce n'est configurée pour cet opérateur (ex: une transaction 'autre')
      // ou si la liste des puces n'est pas encore chargée
      return _getFallbackColor(tx.operateur);
    }

    // Par défaut si la puce existe mais n'a pas de couleur
    return _getFallbackColor(tx.operateur);
  }

  // Petite fonction helper pour la clarté
  Color _getFallbackColor(OperatorType op) {
    switch (op) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);

    // On récupère les puces via Riverpod (comme dans ton AgentHome)
    // Assure-toi que agentNumbersStreamProvider est bien défini dans tes providers
    final puces = ref.watch(agentNumbersStreamProvider(1)).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Historique",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
            // Utilisation du StreamBuilder direct comme dans AgentHome
            child: StreamBuilder<List<Transaction>>(
              stream: db.watchAllTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Erreur : ${snapshot.error}"));
                }

                final allTransactions = snapshot.data ?? [];
                final filtered = _applyFilters(allTransactions);

                if (filtered.isEmpty) return _buildEmptyState(theme);

                return ListView.separated(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final tx = filtered[index];
                    final opColor = _getTransactionColor(tx, puces);

                    return InkWell(
                      onTap: () =>
                          _showTransactionDetails(context, theme, tx, opColor),
                      borderRadius: BorderRadius.circular(16),
                      child: _buildTransactionCard(theme, tx, opColor),
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

  // --- COMPOSANTS UI ---

  Widget _buildTransactionCard(ThemeData theme, Transaction tx, Color opColor) {
    final bool isRetrait = tx.type == TransactionType.retrait;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: opColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: opColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: opColor.withOpacity(0.1),
            child: Icon(
              isRetrait ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
              size: 20,
              color: opColor,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.nomClient?.isNotEmpty == true
                      ? tx.nomClient!
                      : "Client Inconnu",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('dd MMM, HH:mm').format(tx.horodatage),
                  style: theme.textTheme.bodySmall?.copyWith(
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
                  fontSize: 15,
                  color: isRetrait
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: opColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tx.operateur.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- LOGIQUE DE RECHERCHE ET FILTRES ---

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

  // --- AUTRES WIDGETS (Filtres, Détails, DatePicker) ---
  // (Inchangés par rapport à ta version précédente)

  Widget _buildSearchAndFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: "Rechercher...",
              prefixIcon: const Icon(LucideIcons.search, size: 20),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? Colors.white10
                  : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
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
        onSelected: (v) => setState(() => _selectedFilter = label),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        showCheckmark: false,
      ),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    ThemeData theme,
    Transaction tx,
    Color opColor,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: opColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.receipt, color: Colors.white),
              SizedBox(width: 12),
              Text(
                "Récapitulatif",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow(
              "Type",
              tx.type.name.toUpperCase(),
              theme,
              color: opColor,
              isBold: true,
            ),
            _buildDetailRow("Référence", tx.reference, theme),
            _buildDetailRow("Client", tx.nomClient ?? "Inconnu", theme),
            const Divider(height: 24),
            _buildDetailRow(
              "Montant",
              CurrencyFormatter.format(tx.montant),
              theme,
              isBold: true,
            ),
            _buildDetailRow(
              "Date",
              DateFormat('dd/MM/yyyy HH:mm').format(tx.horodatage),
              theme,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("FERMER", style: TextStyle(color: opColor)),
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

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Text(
        "Aucune donnée trouvée",
        style: TextStyle(color: theme.hintColor),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDateRange = picked);
  }
}
