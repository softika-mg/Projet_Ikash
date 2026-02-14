import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

// Modèle temporaire pour les données de test
class TransactionTest {
  final String id;
  final String client;
  final String numero;
  final String operateur;
  final String type;
  final double montant;
  final double frais;
  final DateTime date;

  TransactionTest({
    required this.id,
    required this.client,
    required this.numero,
    required this.operateur,
    required this.type,
    required this.montant,
    required this.frais,
    required this.date,
  });
}

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  String _searchQuery = "";
  String _selectedFilter = "Tous";
  DateTimeRange? _selectedDateRange;

  // Données de test simulant ta base de données
  final List<TransactionTest> _allTransactions = [
    TransactionTest(
      id: "878179170",
      client: "Armand Rakoto",
      numero: "0348503254",
      operateur: "TELMA",
      type: "DEPOT",
      montant: 45000,
      frais: 300,
      date: DateTime.now(),
    ),
    TransactionTest(
      id: "875254271",
      client: "Marie Flavienne",
      numero: "0341376615",
      operateur: "ORANGE",
      type: "RETRAIT",
      montant: 195000,
      frais: 0,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TransactionTest(
      id: "878012262",
      client: "Basile Tarson",
      numero: "0385771148",
      operateur: "AIRTEL",
      type: "DEPOT",
      montant: 500000,
      frais: 1500,
      date: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    TransactionTest(
      id: "CI251216",
      client: "Lanto Nirina",
      numero: "0320543321",
      operateur: "TELMA",
      type: "RETRAIT",
      montant: 20000,
      frais: 208,
      date: DateTime.now(),
    ),
  ];

  // Logique de filtrage
  List<TransactionTest> get _filteredTransactions {
    return _allTransactions.where((tx) {
      // Filtre Recherche (Nom, Numéro ou Réf)
      final matchesSearch =
          tx.client.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.numero.contains(_searchQuery) ||
          tx.id.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filtre Catégorie (Opérateur ou Type)
      bool matchesCategory =
          _selectedFilter == "Tous" ||
          tx.operateur == _selectedFilter ||
          tx.type == _selectedFilter;

      // Filtre Date
      bool matchesDate = true;
      if (_selectedDateRange != null) {
        matchesDate =
            tx.date.isAfter(_selectedDateRange!.start) &&
            tx.date.isBefore(
              _selectedDateRange!.end.add(const Duration(days: 1)),
            );
      }

      return matchesSearch && matchesCategory && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique"),
        actions: [
          if (_selectedDateRange != null)
            IconButton(
              icon: const Icon(LucideIcons.xCircle, size: 20),
              onPressed: () => setState(() => _selectedDateRange = null),
            ),
          IconButton(
            icon: Icon(
              LucideIcons.calendarRange,
              color: _selectedDateRange != null ? theme.primaryColor : null,
            ),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _selectedDateRange = picked);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Barre de Recherche & Filtres Rapides ---
          Container(
            padding: const EdgeInsets.all(16),
            // Utilisation de surfaceVariant ou mélange avec le fond
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: "Chercher un nom, numéro, réf...",
                    prefixIcon: const Icon(LucideIcons.search, size: 20),
                    filled: true,
                    // S'adapte au mode sombre (plus besoin de Colors.white)
                    fillColor: theme.cardColor,
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
          ),

          // --- Liste des Transactions ---
          Expanded(
            child: _filteredTransactions.isEmpty
                ? const Center(child: Text("Aucune transaction trouvée"))
                : ListView.separated(
                    itemCount: _filteredTransactions.length,
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final tx = _filteredTransactions[index];
                      return InkWell(
                        onTap: () =>
                            _showTransactionDetails(context, theme, tx),
                        borderRadius: BorderRadius.circular(16),
                        // On passe le thème pour adapter la carte
                        child: _buildTransactionCard(theme, tx),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- Les détails adaptés ---
  void _showTransactionDetails(
    BuildContext context,
    ThemeData theme,
    TransactionTest tx,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(LucideIcons.fileText, color: theme.primaryColor),
            const SizedBox(width: 10),
            const Text("Détails"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow("Référence", tx.id, theme, isBold: true),
            _buildDetailRow("Client", tx.client, theme),
            _buildDetailRow("Numéro", tx.numero, theme),
            _buildDetailRow("Opérateur", tx.operateur, theme),
            const Divider(height: 30),
            _buildDetailRow(
              "Montant",
              "${tx.montant.toInt()} Ar",
              theme,
              color: theme.colorScheme.primary,
            ),
            _buildDetailRow("Frais", "${tx.frais.toInt()} Ar", theme),
            const Divider(height: 30),
            _buildDetailRow(
              "Date",
              DateFormat('dd/MM/yyyy').format(tx.date),
              theme,
            ),
            _buildDetailRow(
              "Heure",
              DateFormat('HH:mm').format(tx.date),
              theme,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("FERMER"),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.share2, size: 18),
            label: const Text("PARTAGER"),
          ),
        ],
      ),
    );
  }

  // --- La Carte adaptée ---
  Widget _buildTransactionCard(ThemeData theme, TransactionTest tx) {
    final isDark = theme.brightness == Brightness.dark;

    Color opColor = tx.operateur == "TELMA"
        ? Colors.yellow.shade800
        : (tx.operateur == "ORANGE" ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor, // Utilise la couleur de carte du thème
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark) // Ombre uniquement en mode clair pour un look "flat" en sombre
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
        border: isDark
            ? Border.all(color: theme.dividerColor.withOpacity(0.1))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: opColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                tx.operateur[0],
                style: TextStyle(color: opColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.client,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('dd MMM, HH:mm').format(tx.date),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${tx.montant.toInt()} Ar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: tx.type == "DEPOT"
                      ? Colors.green.shade400
                      : Colors.red.shade400,
                ),
              ),
              Text(
                tx.type,
                style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1),
              ),
            ],
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
              color: color ?? theme.textTheme.bodyLarge?.color,
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
        label: Text(label),
        selected: isSelected,
        onSelected: (v) => setState(() => _selectedFilter = label),
        // Le FilterChip utilise par défaut les couleurs du thème Material 3
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
