class TarifMapper {
  static double calculerFraisClient(double montant) {
    if (montant <= 5000) return 700;
    if (montant <= 10000) return 1000;
    if (montant <= 25000) return 2000;
    if (montant <= 50000) return 3000;
    if (montant <= 80000) return 4000;
    if (montant <= 100000) return 4500;
    if (montant <= 250000) return 7000;
    if (montant <= 600000) return 10000;
    if (montant <= 1000000) return 18000;
    if (montant <= 2000000) return 30000;
    return 42000; // Pour 2 000 000 et plus
  }

  static double calculerFraisOperateur(double montant) {
    if (montant <= 5000) return 200;
    if (montant <= 10000) return 300;
    if (montant <= 25000) return 650;
    if (montant <= 50000) return 1300;
    if (montant <= 100000) return 1900;
    if (montant <= 250000) return 3400;
    if (montant <= 600000) return 4700;
    if (montant <= 1000000) return 8800;
    if (montant <= 2000000) return 14700;
    return 19600;
  }
}
