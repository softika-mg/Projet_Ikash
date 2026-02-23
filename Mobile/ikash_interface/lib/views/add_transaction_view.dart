import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as d;

// Assure-toi que ces imports correspondent à ton arborescence
import '../models/enum.dart';
import '../services/transaction_service.dart';
import '../database/app_database.dart';
import '../widgets/status_dialog.dart';
import '../services/tarif_service.dart';

// Provider pour les puces
final agentNumbersStreamProvider = StreamProvider<List<AgentNumber>>((ref) {
  return ref.watch(transactionControllerProvider).watchAllAgentNumbers();
});

class AddTransactionView extends ConsumerStatefulWidget {
  const AddTransactionView({super.key});

  @override
  ConsumerState<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends ConsumerState<AddTransactionView> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _refController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _feeController = TextEditingController(text: '0');
  final _commissionController = TextEditingController(text: '0');
  final _bonusController = TextEditingController(text: '0');

  // États
  String _type = 'DEPOT';
  AgentNumber? _activePuce; // On stocke directement la puce sélectionnée
  final DateTime _now = DateTime.now();

  // Mappers
  TransactionType get _selectedType => TransactionType.values.firstWhere(
    (e) => e.name.toUpperCase() == _type,
    orElse: () => TransactionType.depot,
  );

  OperatorType get _selectedOperator =>
      _activePuce?.operateur ?? OperatorType.telma;

  @override
  void dispose() {
    _refController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _feeController.dispose();
    _commissionController.dispose();
    _bonusController.dispose();
    super.dispose();
  }

  // --- LOGIQUE DE VALIDATION ---
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return "Numéro obligatoire";
    // On retire les espaces pour la vérification
    final cleanNum = value.replaceAll(' ', '');
    if (cleanNum.length != 10) return "Doit contenir 10 chiffres";

    final prefix = cleanNum.substring(0, 3);
    Map<String, List<String>> validPrefixes = {
      'TELMA': ['034', '038'],
      'ORANGE': ['032', '037'],
      'AIRTEL': ['033'],
    };

    final opName = _selectedOperator.name.toUpperCase();
    if (!validPrefixes[opName]!.contains(prefix)) {
      return "Préfixe invalide pour $opName ($prefix)";
    }
    return null;
  }

  // --- MISE À JOUR AUTOMATIQUE DES FRAIS ---
  void _onAmountChanged(String value) {
    // Si on a formaté avec des espaces/virgules, on nettoie d'abord
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    final montant = double.tryParse(cleanValue) ?? 0;

    if (montant == 0 || _activePuce == null) {
      setState(() {
        _feeController.text = '0';
        _bonusController.text = '0';
      });
      return;
    }

    final tarifsAsync = ref.read(tarifsStreamProvider);

    tarifsAsync.whenData((liste) {
      try {
        final tarifMatch = liste.firstWhere(
          (t) =>
              t.operateur == _selectedOperator &&
              montant >= t.montantMin &&
              montant <= t.montantMax,
        );

        setState(() {
          _feeController.text = tarifMatch.fraisClient.toInt().toString();
          final gainEstime = tarifMatch.fraisClient - tarifMatch.fraisOperateur;
          _bonusController.text = gainEstime.toInt().toString();
        });
      } catch (e) {
        setState(() {
          _feeController.text = '0';
          _bonusController.text = '0';
        });
      }
    });
  }

  // --- DIALOGUE DE CONFIRMATION ---
  Future<void> _confirmAndSave(Color activeColor) async {
    if (!_formKey.currentState!.validate()) return;
    if (_activePuce == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez sélectionner une puce.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final formatter = NumberFormat("#,###", "fr_FR");
    final montant =
        double.tryParse(_amountController.text.replaceAll(' ', '')) ?? 0;
    final frais = double.tryParse(_feeController.text) ?? 0;

    // Affiche le récapitulatif
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.shieldCheck, color: activeColor),
            const SizedBox(width: 10),
            const Text("Confirmer l'opération"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecapRow("Type", _type, isBold: true),
            _buildRecapRow(
              "Puce",
              "${_activePuce!.operateur.name.toUpperCase()} (${_activePuce!.numeroPuce})",
            ),
            _buildRecapRow("Client", _phoneController.text),
            if (_nameController.text.isNotEmpty)
              _buildRecapRow("Nom", _nameController.text),
            const Divider(height: 20),
            _buildRecapRow(
              "Montant",
              "${formatter.format(montant)} Ar",
              isBold: true,
              color: activeColor,
            ),
            _buildRecapRow("Frais", "${formatter.format(frais)} Ar"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: activeColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Valider",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _handleSave(activeColor);
    }
  }

  Widget _buildRecapRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  // --- SAUVEGARDE EN BASE ---
  Future<void> _handleSave(Color activeColor) async {
    try {
      final montant =
          double.tryParse(_amountController.text.replaceAll(' ', '')) ?? 0;
      final frais = double.tryParse(_feeController.text) ?? 0;
      final bonus = double.tryParse(_bonusController.text) ?? 0;

      final companion = TransactionsCompanion.insert(
        type: _selectedType,
        operateur: _selectedOperator,
        reference: _refController.text,
        montant: montant,
        horodatage: d.Value(_now),
        agentId: _activePuce!.id,
        numeroClient: d.Value(_phoneController.text),
        nomClient: d.Value(_nameController.text),
        commission: d.Value(_commissionController.text),
        bonus: d.Value(bonus),
        fraisClient: d.Value(frais),
        agentNumberId: d.Value(_activePuce!.id),
      );

      await ref.read(transactionControllerProvider).saveTransaction(companion);

      if (mounted) {
        AppStatusDialog.show(
          context,
          title: "Succès !",
          message: "Transaction enregistrée avec succès.",
        );
        _refController.clear();
        _amountController.clear();
        _phoneController.clear();
        _nameController.clear();
        _feeController.text = '0';
        _commissionController.text = "0";
      }
    } catch (e) {
      if (mounted) {
        AppStatusDialog.show(
          context,
          title: "Erreur",
          message: e.toString(),
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pucesAsync = ref.watch(agentNumbersStreamProvider);

    // Couleur active basée sur la puce sélectionnée, ou primaryColor par défaut
    Color activeColor = theme.primaryColor;
    if (_activePuce != null && _activePuce!.color != null) {
      activeColor = Color(int.parse(_activePuce!.color!));
    } else if (_activePuce != null) {
      // Fallback
      switch (_activePuce!.operateur) {
        case OperatorType.telma:
          activeColor = Colors.yellow.shade800;
          break;
        case OperatorType.orange:
          activeColor = Colors.orange;
          break;
        case OperatorType.airtel:
          activeColor = Colors.red;
          break;
        default:
          activeColor = theme.primaryColor;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nouvelle Transaction",
          style: TextStyle(color: activeColor),
        ),
        iconTheme: IconThemeData(color: activeColor),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInfoBadge(
                      activeColor,
                      LucideIcons.calendar,
                      "Le ${DateFormat('dd/MM/yy à HH:mm').format(_now)}",
                    ),
                    const SizedBox(height: 25),

                    // --- SÉLECTEUR DE PUCES DYNAMIQUE ---
                    pucesAsync.when(
                      data: (puces) {
                        if (puces.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Veuillez d'abord configurer vos puces dans les paramètres.",
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        // Auto-sélection de la première puce si rien n'est sélectionné
                        if (_activePuce == null) {
                          Future.microtask(
                            () => setState(() => _activePuce = puces.first),
                          );
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: puces.map((puce) {
                              final isSelected = _activePuce?.id == puce.id;
                              final puceColor = puce.color != null
                                  ? Color(int.parse(puce.color!))
                                  : theme.primaryColor;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ActionChip(
                                  avatar: Icon(
                                    Icons.sim_card,
                                    size: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : puceColor,
                                  ),
                                  label: Text(
                                    "${puce.operateur.name.toUpperCase()} (${puce.numeroPuce.substring(0, 3)}...)",
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : puceColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: isSelected
                                      ? puceColor
                                      : theme.cardColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: isSelected
                                          ? Colors.transparent
                                          : puceColor.withOpacity(0.3),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() => _activePuce = puce);
                                    if (_amountController.text.isNotEmpty) {
                                      _onAmountChanged(_amountController.text);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (err, _) => Text("Erreur : $err"),
                    ),
                    const SizedBox(height: 25),

                    // Types de transactions
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

                    _buildTextField(
                      controller: _refController,
                      theme: theme,
                      activeColor: activeColor,
                      label: "Référence",
                      hint: "ID Transaction",
                      icon: LucideIcons.hash,
                    ),
                    const SizedBox(height: 15),

                    // Champ Numéro Client avec formatage automatique
                    _buildTextField(
                      controller: _phoneController,
                      theme: theme,
                      activeColor: activeColor,
                      label: "Numéro Client",
                      hint: "03X XX XXX XX",
                      icon: LucideIcons.phone,
                      validator: _validatePhoneNumber,
                      keyboardType: TextInputType.phone,
                      formatters: [
                        PhoneInputFormatter(),
                      ], // <-- Application du formatteur ici
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _nameController,
                      theme: theme,
                      activeColor: activeColor,
                      label: "Nom Client",
                      hint: "Facultatif",
                      icon: LucideIcons.user,
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(),
                    ),

                    _buildTextField(
                      controller: _amountController,
                      theme: theme,
                      activeColor: activeColor,
                      label: "Montant (Ar)",
                      hint: "0",
                      icon: LucideIcons.banknote,
                      isAmount: true,
                      onChanged: _onAmountChanged,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _feeController,
                            theme: theme,
                            activeColor: activeColor,
                            label: "Frais Client",
                            hint: "Auto",
                            icon: LucideIcons.plusCircle,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildTextField(
                            controller: _bonusController,
                            theme: theme,
                            activeColor: activeColor,
                            label: "Gain estimé",
                            hint: "Auto",
                            icon: LucideIcons.trendingUp,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _commissionController,
                      theme: theme,
                      activeColor: activeColor,
                      label: "Commission",
                      hint: "0",
                      icon: LucideIcons.archive,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildSaveButton(theme, activeColor),
        ],
      ),
    );
  }

  // --- WIDGETS UI HELPER ---

  Widget _buildTextField({
    required TextEditingController controller,
    required ThemeData theme,
    required Color activeColor,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool isAmount = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator ?? (v) => v!.isEmpty ? "Requis" : null,
          onChanged: onChanged,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          style: TextStyle(
            fontSize: isAmount ? 22 : 16,
            fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: activeColor),
            hintText: hint,
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? Colors.white10
                : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: activeColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ThemeData theme, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: theme.cardColor,
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () => _confirmAndSave(
              color,
            ), // <-- Changement ici pour appeler la boîte de dialogue
            child: const Text(
              "VALIDER L'OPÉRATION",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
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
          color: isSelected ? color.withOpacity(0.1) : theme.cardColor,
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
                fontSize: 10,
                color: isSelected ? color : theme.hintColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(Color color, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// --- CLASSE POUR LE FORMATAGE DU TÉLÉPHONE ---
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Enlever tout ce qui n'est pas un chiffre
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 2. Limiter à 10 chiffres maximum
    if (text.length > 10) {
      text = text.substring(0, 10);
    }

    // 3. Appliquer le format 03X XX XXX XX
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      // Ajouter un espace après le 3ème, 5ème et 8ème chiffre
      if (i == 3 || i == 5 || i == 8) {
        formatted += ' ';
      }
      formatted += text[i];
    }

    // 4. Retourner la nouvelle valeur avec le curseur à la fin
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
