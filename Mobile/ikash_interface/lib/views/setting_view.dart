import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paramètres")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(LucideIcons.moon),
            title: const Text("Mode Sombre"),
            trailing: Switch(value: true, onChanged: (v) {}),
          ),
          ListTile(
            leading: const Icon(LucideIcons.lock),
            title: const Text("Changer le code PIN"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(LucideIcons.database),
            title: const Text("Sauvegarde des données"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(LucideIcons.trash2, color: Colors.red),
            title: const Text(
              "Réinitialiser l'application",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
