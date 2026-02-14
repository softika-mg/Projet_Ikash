import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Version moderne sans StateNotifier
class ThemeNotifier extends Notifier<bool> {
  static const String _themeKey = "isDarkMode";

  @override
  bool build() {
    // Au démarrage, on peut essayer de lire la valeur,
    // mais build() doit être rapide. On initialise et on charge.
    _loadTheme();
    return false; // Valeur par défaut temporaire
  }

  // Charger la valeur sauvegardée
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_themeKey) ?? false;
  }

  // Changer et Sauvegarder
  Future<void> toggleTheme() async {
    state = !state; // Change l'interface immédiatement

    // Sauvegarde dans la mémoire du téléphone
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, state);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, bool>(ThemeNotifier.new);
