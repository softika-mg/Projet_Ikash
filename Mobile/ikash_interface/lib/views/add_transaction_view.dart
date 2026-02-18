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
import '../services/tarif_service.dart';
import '../database/app_database.dart';



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

  // --- LOGIQUE DE VALIDATION DES PRÉFIXES ---
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return "Numéro obligatoire";
    final cleanNum = value.replaceAll(' ', '');
    if (cleanNum.length != 10) return "Doit contenir 10 chiffres";

    final prefix = cleanNum.substring(0, 3);
    Map<String, List<String>> validPrefixes = {
      'TELMA': ['034', '038'],
      'ORANGE': ['032', '037'],
      'AIRTEL': ['033'],
    };

    if (!validPrefixes[_operator]!.contains(prefix)) {
      return "Préfixe invalide pour $_operator ($prefix)";
    }
    return null;
  }
  void _onAmountChanged(String value) {
    final montant = double.tryParse(value) ?? 0;
    if (montant == 0) return;

    // On récupère la liste des tarifs depuis le provider
    final tarifsAsync = ref.read(tarifsStreamProvider);

    tarifsAsync.whenData((liste) {
      try {
        // On cherche la tranche correspondante
        final tarifMatch = liste.firstWhere((t) =>
          t.operateur == _selectedOperator &&
          montant >= t.montantMin &&
          montant <= t.montantMax
        );

        setState(() {
          _feeController.text = tarifMatch.fraisClient.toInt().toString();
          // Commission estimée (Gain de l'agence)
          final gain = tarifMatch.fraisClient - tarifMatch.fraisOperateur;
          _commissionController.text = gain.toInt().toString();
        });
      } catch (e) {
        // Pas de tranche trouvée
      }
    });
  }

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

        // --- LOGIQUE Puce avec ou sans ID ---
        int agentPuceId = 0;
        try {
        final agentNumbers = await ref.read(transactionControllerProvider).getAllAgentNumbers();
        final correctNumber = agentNumbers.firstWhere((n) => n.operateur == _selectedOperator);
        agentPuceId = correctNumber.id;
          } catch (e) {
        // Si aucune puce n'est trouvée, on reste à 0
        if (_selectedType == TransactionType.depot || _selectedType == TransactionType.retrait) {
           throw Exception("Une puce officielle est requise pour les Dépôts/Retraits.");
        }
        // Pour Crédit/Transfert, on laisse agentPuceId à 0
      }

        final companion = TransactionsCompanion.insert(
          type: _selectedType,
          operateur: _selectedOperator,
          reference: _refController.text,
          montant: montant,
          horodatage: d.Value(_now),
          agentId: agentPuceId, // Peut être null pour les puces simples
          bonus: d.Value(frais),
          numeroClient: d.Value(_phoneController.text),
          nomClient: d.Value(_nameController.text),
        );

        await ref.read(transactionControllerProvider).saveTransaction(companion);

        if (mounted) {
          AppStatusDialog.show(context, title: "Succès !", message: "Transaction enregistrée avec succès.");
          _refController.clear();
          _amountController.clear();
          _phoneController.clear();
        }
      } catch (e) {
        if (mounted) {
          AppStatusDialog.show(context, title: "Erreur", message: e.toString(), isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Nouvelle Transaction"), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInfoBadge(theme, LucideIcons.calendar, "Le ${DateFormat('dd/MM/yy à HH:mm').format(_now)}"),
                    const SizedBox(height: 20),

                    // Opérateurs
                    Row(children: [
                      _buildOperatorChip("TELMA", Colors.yellow.shade800, theme),
                      const SizedBox(width: 8),
                      _buildOperatorChip("ORANGE", Colors.orange, theme),
                      const SizedBox(width: 8),
                      _buildOperatorChip("AIRTEL", Colors.red, theme),
                    ]),
                    const SizedBox(height: 25),

                    // Types
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        _buildTypeOption("DEPOT", LucideIcons.download, Colors.green, theme),
                        const SizedBox(width: 10),
                        _buildTypeOption("RETRAIT", LucideIcons.upload, Colors.blue, theme),
                        const SizedBox(width: 10),
                        _buildTypeOption("TRANSFERT", LucideIcons.repeat, Colors.purple, theme),
                        const SizedBox(width: 10),
                        _buildTypeOption("CREDIT", LucideIcons.phoneCall, Colors.teal, theme),
                      ]),
                    ),
                    const SizedBox(height: 30),

                    _buildTextField(controller: _refController, theme: theme, label: "Référence", hint: "ID Transaction", icon: LucideIcons.hash),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _phoneController,
                      theme: theme,
                      label: "Numéro Client",
                      hint: "03X XX XXX XX",
                      icon: LucideIcons.phone,
                      validator: _validatePhoneNumber,
                      keyboardType: TextInputType.phone
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(controller: _nameController, theme: theme, label: "Nom Client", hint: "Facultatif", icon: LucideIcons.user),

                    const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),

                    _buildTextField(
                      controller: _amountController,
                      theme: theme,
                      label: "Montant (Ar)",
                      hint: "0",
                      icon: LucideIcons.banknote,
                      isAmount: true,
                      onChanged: _onAmountChanged, // Déclenche le calcul
                      keyboardType: TextInputType.number
                    ),
                    const SizedBox(height: 15),

                    Row(children: [
                      Expanded(child: _buildTextField(controller: _feeController, theme: theme, label: "Frais Client", hint: "Auto", icon: LucideIcons.plusCircle)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildTextField(controller: _commissionController, theme: theme, label: "Gain estimé", hint: "Auto", icon: LucideIcons.trendingUp)),
                    ]),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          _buildSaveButton(theme),
        ],
      ),
    );
  }
  Widget _buildSaveButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: theme.cardColor,
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: _handleSave,
            child: const Text("VALIDER L'OPÉRATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required ThemeData theme,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool isAmount = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator ?? (v) => v!.isEmpty ? "Requis" : null,
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: isAmount ? 22 : 16, fontWeight: isAmount ? FontWeight.bold : FontWeight.normal),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: theme.primaryColor),
            hintText: hint,
            filled: true,
            fillColor: theme.brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
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
}
