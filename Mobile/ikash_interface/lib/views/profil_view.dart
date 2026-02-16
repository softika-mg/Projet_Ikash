import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:drift/drift.dart' as d;
import '../database/app_database.dart';
import '../models/enum.dart';
import '../core/utils/formatters.dart';
import '../services/auth_service.dart';

class ProfilView extends ConsumerStatefulWidget {
  const ProfilView({super.key});

  @override
  ConsumerState<ProfilView> createState() => _ProfilViewState();
}

class _ProfilViewState extends ConsumerState<ProfilView> {
  int get currentAgentId => ref.read(currentUserProvider)?.id ?? 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);
    // 1. On récupère l'utilisateur actuellement connecté
    final currentUser = ref.watch(currentUserProvider);



    // Sécurité au cas où on arrive sur cette page sans être connecté
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Veuillez vous reconnecter")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<Profile>(
        stream: db.watchProfile(currentAgentId),
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = profileSnapshot.data;

          return StreamBuilder<List<AgentNumber>>(
            stream: db.watchAgentNumbers(currentAgentId),
            builder: (context, snapshot) {
              final puces = snapshot.data ?? [];

              // Calcul du solde total
              final double soldeTotalCalcule = puces.fold(0, (sum, item) => sum + item.soldePuce);

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // --- Header Profil ---
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          child: Icon(
                            LucideIcons.user,
                            size: 55,
                            color: theme.primaryColor,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _showEditProfileName(context, profile),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: theme.colorScheme.primary,
                              child: const Icon(LucideIcons.pencil, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- Informations Agent ---
                  // --- Informations Agent ---
if (profile != null) ...[
  _buildInfoTile(
    // On utilise 'profile' au lieu de 'user'
    profile.role == RoleType.admin ? "Nom de l'administrateur" : "Nom de l'agent",

    // Valeur affichée (avec fallback si le nom est vide ou égal à "Administrateur")
    (profile.nom.isEmpty || profile.nom == "Administrateur")
        ? (profile.role == RoleType.admin ? "Admin Principal" : "Agent")
        : profile.nom,

    profile.role == RoleType.admin ? LucideIcons.shieldCheck : LucideIcons.user,
    theme,
  ),
],

                  _buildInfoTile(
                    "Solde Global (Cumulé)",
                    // Utilisation du Formatter ici
                    CurrencyFormatter.format(soldeTotalCalcule),
                    LucideIcons.wallet,
                    theme,
                    // On applique la couleur dynamique (Vert si > 0)
                    valueColor: CurrencyFormatter.getAmountColor(soldeTotalCalcule),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),

                  // --- Dashboard des Puces ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "MES PUCES DE TRAVAIL",
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      if (puces.length < 3)
                        TextButton.icon(
                          onPressed: () => _showEditNumberDialog(context, null),
                          icon: const Icon(LucideIcons.plus, size: 18),
                          label: const Text("Ajouter"),
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  if (puces.isEmpty)
                    _buildEmptyState()
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: puces.length,
                      itemBuilder: (context, index) {
                        return _buildPuceCard(puces[index], theme);
                      },
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // --- Widget: Carte de Puce avec Formatter ---
  Widget _buildPuceCard(AgentNumber puce, ThemeData theme) {
    final color = _getOpColor(puce.operateur);

    return InkWell(
      onTap: () => _showEditNumberDialog(context, puce),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(LucideIcons.smartphone, color: color, size: 22),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    puce.operateur.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            // Montant formaté ici
            Text(
              CurrencyFormatter.format(puce.soldePuce),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: -0.5
              ),
            ),
            Text(
              puce.numeroPuce,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Info Tile réutilisable ---
  Widget _buildInfoTile(
    String label,
    String value,
    IconData icon,
    ThemeData theme, {
    Color? valueColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: theme.primaryColor, size: 22),
      ),
      title: Text(label, style: theme.textTheme.bodySmall),
      subtitle: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: valueColor ?? theme.textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 30),
          Icon(LucideIcons.info, color: Colors.grey.shade400, size: 40),
          const SizedBox(height: 10),
          const Text("Configurez vos puces pour commencer"),
        ],
      ),
    );
  }

  // --- Dialogues (Logique inchangée mais intégrée) ---

  void _showEditProfileName(BuildContext context, Profile? profile) {
    final nameController = TextEditingController(text: profile?.nom);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modifier le profil"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Nom de l'agent"),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await (db.update(db.profiles)..where((t) => t.id.equals(currentAgentId))).write(
                ProfilesCompanion(nom: d.Value(nameController.text)),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Sauvegarder"),
          ),
        ],
      ),
    );
  }

  void _showEditNumberDialog(BuildContext context, AgentNumber? puce) {
    final numController = TextEditingController(text: puce?.numeroPuce);
    final soldeController = TextEditingController(
      text: puce?.soldePuce.toInt().toString(),
    );
    OperatorType selectedOp = puce?.operateur ?? OperatorType.telma;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(puce == null ? "Nouvelle Puce" : "Modifier la Puce"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (puce == null)
                DropdownButtonFormField<OperatorType>(
                  value: selectedOp,
                  items: OperatorType.values
                      .map((op) => DropdownMenuItem(
                            value: op,
                            child: Text(op.name.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedOp = val!),
                  decoration: const InputDecoration(labelText: "Opérateur"),
                ),
              TextField(
                controller: numController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Numéro de téléphone"),
              ),
              TextField(
                controller: soldeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Solde initial (Ar)"),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () async {
                final db = ref.read(databaseProvider);
                await db.saveAgentNumber(
                  AgentNumbersCompanion(
                    id: puce != null ? d.Value(puce.id) : const d.Value.absent(),
                    profileId: d.Value(currentAgentId),
                    operateur: d.Value(selectedOp),
                    numeroPuce: d.Value(numController.text),
                    soldePuce: d.Value(double.tryParse(soldeController.text) ?? 0),
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }

  Color _getOpColor(OperatorType type) {
    switch (type) {
      case OperatorType.telma: return Colors.yellow.shade800;
      case OperatorType.orange: return Colors.orange.shade700;
      case OperatorType.airtel: return Colors.red.shade700;
      default: return Colors.grey;
    }
  }
}
