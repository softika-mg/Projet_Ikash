import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';

// Services et Providers
import '../services/auth_service.dart';
import '../database/app_database.dart';
import '../services/backup_services.dart';
import '../services/bio_auth_service.dart';
import '../providers/theme_provider.dart';
import '../models/enum.dart';
import '../widgets/status_dialog.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final backupService = ref.read(backupServiceProvider);
    final db = ref.read(databaseProvider);
    final bioService = ref.read(bioAuthProvider);
    final isBioEnabled = ref.watch(bioConfigProvider);

    // Récupération de l'utilisateur actuel
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Paramètres"), centerTitle: true),
      body: ListView(
        children: [
          const _SectionHeader(title: "Apparence & Visibilité"),

          // --- MODE SOMBRE ---
          ListTile(
            leading: const Icon(LucideIcons.moon),
            title: const Text("Mode Sombre"),
            subtitle: const Text("Ajuster l'interface pour la nuit"),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (v) => ref.read(themeProvider.notifier).toggleTheme(),
            ),
          ),

          const Divider(),
          const _SectionHeader(title: "Sécurité"),

          // --- EMPREINTE DIGITALE (Logique Admin) ---
          if (currentUser?.role == RoleType.admin)
            ListTile(
              leading: const Icon(LucideIcons.fingerprint),
              title: const Text("Empreinte Digitale"),
              subtitle: const Text("Authentification biométrique pour l'Admin"),
              trailing: Switch(
                value: isBioEnabled,
                onChanged: (bool value) async {
                  final bioNotifier = ref.read(bioConfigProvider.notifier);

                  if (value == true) {
                    // Vérification de la compatibilité matérielle
                    if (await bioService.canAuthenticate()) {
                      bool authenticated = await bioService.authenticateAdmin();
                      if (authenticated) {
                        await bioNotifier.toggleBio(true);
                        if (context.mounted) {
                          _showStatus(
                            context,
                            "Biométrie activée !",
                            "Vous avez réussi l'activation de l'empreinte digitale",
                            false,
                          );
                        }
                      }
                    } else {
                      if (context.mounted) {
                        _showStatus(
                          context,
                          "Matériel non supporté",
                          "Votre appareil n'est pas équipé d'un lecteur d'empreinte",
                          true,
                        );
                      }
                    }
                  } else {
                    await bioNotifier.toggleBio(false);
                  }
                },
              ),
            ),

          // --- CHANGEMENT DE PIN ---
          ListTile(
            leading: const Icon(LucideIcons.lock),
            title: const Text("Changer le code PIN"),
            subtitle: const Text("Sécuriser l'accès à vos comptes"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Fonctionnalité bientôt disponible"),
                ),
              );
            },
          ),

          // --- SECTION DONNÉES (Seulement pour Admin) ---
          if (currentUser?.role == RoleType.admin) ...[
            const Divider(),
            const _SectionHeader(title: "Données & Sauvegarde"),
            ListTile(
              leading: const Icon(LucideIcons.uploadCloud),
              title: const Text("Sauvegarder les données"),
              subtitle: const Text("Exporter vos transactions en JSON"),
              onTap: () async => await backupService.exportBackup(),
            ),
            ListTile(
              leading: const Icon(LucideIcons.downloadCloud),
              title: const Text("Importer une sauvegarde"),
              subtitle: const Text(
                "Restaurer vos données après réinstallation",
              ),
              onTap: () => _handleImport(context, backupService),
            ),
          ],

          const Divider(),
          const _SectionHeader(title: "Maintenance"),

          // --- RÉINITIALISATION ---
          ListTile(
            leading: const Icon(LucideIcons.trash2, color: Colors.red),
            title: const Text(
              "Réinitialiser l'application",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Effacer l'historique local"),
            onTap: () => _showResetDialog(context, ref), // On passe ref
          ),

          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                const Text(
                  "iKash Mobile v1.0.0",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  "Connecté en tant que ${currentUser?.nom ?? 'Utilisateur'}",
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Fonction utilitaire pour afficher ton AppStatusDialog
  void _showStatus(
    BuildContext context,
    String title,
    String message,
    bool isError,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          AppStatusDialog(title: title, message: message, isError: isError),
    );
  }

  // --- LOGIQUE D'IMPORTATION ---
  Future<void> _handleImport(
    BuildContext context,
    BackupService service,
  ) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      bool success = await service.importBackup(content);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? "Données restaurées !" : "Erreur lors de l'import",
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  // --- DIALOGUE DE CONFIRMATION ---
  // --- DIALOGUE DE CONFIRMATION AVEC BACKUP ET BIO ---
  void _showResetDialog(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    final backupService = ref.read(backupServiceProvider);
    final bioService = ref.read(bioAuthProvider);
    final isBioEnabled = ref.read(bioConfigProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: Colors.red),
            SizedBox(width: 10),
            Text("Zone de Danger"),
          ],
        ),
        content: const Text(
          "La réinitialisation va supprimer toutes vos transactions et puces. "
          "Une sauvegarde de sécurité sera générée automatiquement avant la suppression.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // 1. Fermer le dialogue de confirmation
              Navigator.pop(context);

              try {
                // 2. Exportation forcée
                await backupService.exportBackup();

                // 3. Vérification Biométrique (si l'admin l'a configurée)
                bool canProceed = true;
                if (isBioEnabled) {
                  canProceed = await bioService.authenticateAdmin();
                }

                if (canProceed) {
                  // 4. Suppression des données
                  await db.transaction(() async {
                    await db.delete(db.transactions).go();
                    await db.delete(db.agentNumbers).go();
                    // Ajoute ici d'autres tables si nécessaire (smsReceived, etc.)
                  });

                  if (context.mounted) {
                    _showStatus(
                      context,
                      "Réinitialisation réussie",
                      "Les données ont été effacées. Un backup a été créé.",
                      false,
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  _showStatus(
                    context,
                    "Erreur",
                    "L'opération a été interrompue : $e",
                    true,
                  );
                }
              }
            },
            child: const Text(
              "Exporter & Réinitialiser",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor.withOpacity(0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
