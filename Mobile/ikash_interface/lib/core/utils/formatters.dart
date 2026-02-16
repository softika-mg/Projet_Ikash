import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  /// Formate le montant avec une gestion précise de la locale
  static String format(
    num amount, {
    String symbol = "Ar",
    bool showFree = true,
    int decimalDigits = 0,
  }) {
    if (showFree && amount == 0) return "Gratuit";

    // Utiliser le formateur monétaire natif est souvent plus fiable
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: symbol,
      decimalDigits: decimalDigits,
      customPattern: '#,### ¤', // ¤ représente le symbole
    );

    // On remplace les virgules de groupe par des espaces si nécessaire
    return formatter.format(amount).replaceAll('\u00A0', ' ').trim();
  }

  static Color getAmountColor(num amount, {Color defaultColor = Colors.grey}) {
    if (amount > 0) return Colors.green.shade700; // Un vert plus lisible
    if (amount < 0) return Colors.red.shade700;
    return defaultColor;
  }
}
