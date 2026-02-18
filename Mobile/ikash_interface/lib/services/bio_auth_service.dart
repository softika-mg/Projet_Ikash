import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BioConfigNotifier extends Notifier<bool> {
  static const _storageKey = 'isBioEnabled';
  late SharedPreferences _prefs; // On garde une référence

  @override
  bool build() {
    // On lance le chargement initial
    _init();
    return false;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    state = _prefs.getBool(_storageKey) ?? false;
  }

  Future<void> toggleBio(bool enabled) async {
    // On met à jour l'interface instantanément
    state = enabled;
    // On sauvegarde en arrière-plan
    await _prefs.setBool(_storageKey, enabled);
  }
}

final bioConfigProvider = NotifierProvider<BioConfigNotifier, bool>(
  BioConfigNotifier.new,
);

class BioAuthService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> canAuthenticate() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<bool> authenticateAdmin() async {
    try {
      return await auth.authenticate(
        localizedReason:
            'Authentification Admin requise pour accéder aux privilèges',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}

final bioAuthProvider = Provider((ref) => BioAuthService());
