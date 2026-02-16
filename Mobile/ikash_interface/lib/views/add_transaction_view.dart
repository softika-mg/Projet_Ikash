import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/enum.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import 'package:drift/drift.dart' as d;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../widgets/status_dialog.dart';
import '../providers/agent_number_provider.dart';



class AddTransactionView extends ConsumerStatefulWidget {
  const AddTransactionView({super.key});

  @override
  ConsumerState<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends ConsumerState<AddTransactionView> {
  final _formKey = GlobalKey<FormState>();
  // Contrôleurs de texte
  final _refController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _feeController = TextEditingController(text: '0');
  final _commissionController = TextEditingController(text: '0');

  // États du formulaire
  String _type = 'DEPOT';
  String _operator = 'TELMA';
  final DateTime _now = DateTime.now();

  // Mapper pour les Enums
  TransactionType get _selectedType => TransactionType.values.firstWhere(
    (e) => e.name.toUpperCase() == _type,

    orElse: () => TransactionType.depot,
  );

  OperatorType get _selectedOperator => OperatorType.values.firstWhere(
    (e) => e.name.toUpperCase() == _operator,

    orElse: () => OperatorType.telma,
  );

  @override
  void dispose() {
    // Très important : libérer la mémoire
    _refController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _feeController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      try {
        final montant = double.tryParse(_amountController.text) ?? 0;
        final frais = double.tryParse(_feeController.text) ?? 0;
        // --- NOUVELLE LOGIQUE DE LIAISON ---
      // 1. On cherche le numéro enregistré pour cet opérateur
      final agentNumbers = await ref.read(transactionControllerProvider).getAllAgentNumbers();
      final correctNumber = agentNumbers.firstWhere(
        (n) => n.operateur == _selectedOperator,
        orElse: () => throw Exception("Aucun numéro configuré pour $_operator"),
      );
      // -----------------------------------

        final companion = TransactionsCompanion.insert(
          type: _selectedType,
          operateur: _selectedOperator,
          reference: _refController.text,
          montant: montant,
          horodatage: d.Value(_now),
          // On lie la transaction à l'ID de la puce trouvée !
          agentId: correctNumber.id,
          bonus: d.Value(frais),
          numeroClient: d.Value(_phoneController.text),
          nomClient: d.Value(_nameController.text),

          // Ajoute ici tes autres champs (frais, commission, etc.) selon ton .drift
        );

        await ref
            .read(transactionControllerProvider)
            .saveTransaction(companion);

        if (mounted) {
          // Utilisation du nouveau widget
          AppStatusDialog.show(
            context,
            title: "Succès !",
            message: "La transaction ${_refController.text} a été enregistrée.",
          );

          // On vide les champs après succès si on veut rester sur la page,
          // ou on attend un peu avant de faire Navigator.pop
          _refController.clear();
          _amountController.clear();
        }
      } catch (e) {
        if (mounted) {
          AppStatusDialog.show(
            context,
            title: "Oups !",
            message: "Impossible d'enregistrer : $e",
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Numérisation SMS"),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Horodatage Automatique ---
                    _buildInfoBadge(
                      theme,
                      LucideIcons.calendar,
                      "Le ${DateFormat('dd/MM/yy à HH:mm').format(_now)}",
                    ),
                    const SizedBox(height: 20),

                    // --- Choix de l'Opérateur ---
                    Text("Opérateur", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildOperatorChip(
                          "TELMA",
                          Colors.yellow.shade800,
                          theme,
                        ),
                        const SizedBox(width: 8),
                        _buildOperatorChip("ORANGE", Colors.orange, theme),
                        const SizedBox(width: 8),
                        _buildOperatorChip("AIRTEL", Colors.red, theme),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // --- Type de transaction ---
                    Text(
                      "Type d'opération",
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTypeOption(
                            "DEPOT",
                            LucideIcons.download,
                            Colors.green,
                            theme,
                          ),
                          const SizedBox(width: 10),
                          _buildTypeOption(
                            "RETRAIT",
                            LucideIcons.upload,
                            Colors.blue,
                            theme,
                          ),
                          const SizedBox(width: 10),
                          _buildTypeOption(
                            "TRANSFERT",
                            LucideIcons.repeat,
                            Colors.purple,
                            theme,
                          ),
                          const SizedBox(width: 10),
                          _buildTypeOption(
                            "CREDIT",
                            LucideIcons.phoneCall,
                            Colors.teal,
                            theme,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- Champs d'identification ---
                    _buildTextField(
                      controller: _refController, // Ajouté
                      theme: theme,
                      label: "Référence (ID)",
                      hint: "Ref: 878...",
                      icon: LucideIcons.hash,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _phoneController, // Ajouté
                      theme: theme,
                      label: "Numéro Client",
                      hint: "03X XX XXX XX",
                      icon: LucideIcons.user,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _nameController,
                      theme: theme,
                      label: "Nom du Client",
                      hint: "Nom complet",
                      icon: LucideIcons.contact,
                    ),

                    const SizedBox(height: 25),
                    const Divider(),
                    const SizedBox(height: 25),

                    // --- Montant et Calculs ---
                    _buildTextField(
                      controller: _amountController,
                      theme: theme,
                      label: "Montant Principal (Ar)",
                      hint: "0",
                      icon: LucideIcons.banknote,
                      isAmount: true,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _feeController,
                            theme: theme,
                            label: (_type == 'DEPOT' || _type == 'TRANSFERT')
                                ? "Frais (Ar)"
                                : "Bonus (Ar)",
                            hint: "0",
                            icon: LucideIcons.plusCircle,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildTextField(
                            controller: _commissionController,
                            theme: theme,
                            label: "Commission (Ar)",
                            hint: "0",
                            icon: LucideIcons.coins,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          // --- Bouton Enregistrer Stické ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
              ],
              border: isDark
                  ? Border(
                      top: BorderSide(
                        color: theme.dividerColor.withOpacity(0.1),
                      ),
                    )
                  : null,
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    // 1. On valide le formulaire (les champs rouges s'affichent si besoin)
                    if (_formKey.currentState!.validate()) {
                      // 2. On attend que la sauvegarde soit terminée
                      await _handleSave();

                      // Note : Le Navigator.pop est maintenant géré à l'intérieur de _handleSave
                      // après que l'utilisateur a cliqué sur "COMPRIS" dans le dialogue,
                      // OU tu peux le laisser ici si tu préfères fermer la page automatiquement.
                    }
                  },
                  child: const Text(
                    "ENREGISTRER LA TRANSACTION",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers UI ---

  Widget _buildOperatorChip(String name, Color color, ThemeData theme) {
    bool isSelected = _operator == name;
    return Expanded(
      child: ActionChip(
        label: Center(
          child: Text(
            name,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        backgroundColor: isSelected ? color : theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? Colors.transparent : color.withOpacity(0.5),
          ),
        ),
        onPressed: () => setState(() => _operator = name),
      ),
    );
  }

  Widget _buildTypeOption(
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    bool isSelected = _type == value;
    return InkWell(
      onTap: () => setState(() => _type = value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : theme.cardColor,
          border: Border.all(
            color: isSelected ? color : theme.dividerColor.withOpacity(0.1),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : theme.hintColor, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color : theme.hintColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(ThemeData theme, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.primaryColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller, // Ajouté
    TextInputType? keyboardType,
    bool isAmount = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, // Assignation du controller
          keyboardType: keyboardType,
          validator: (v) => v!.isEmpty ? "Obligatoire" : null,
          style: isAmount
              ? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              size: 20,
              color: theme.primaryColor.withOpacity(0.7),
            ),
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? Colors.white10
                : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
