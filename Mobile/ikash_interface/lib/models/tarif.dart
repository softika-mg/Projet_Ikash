import 'package:drift/drift.dart';
import '../models/enum.dart'; // Pour OperatorType

@DataClassName('TarifData')
class Tarifs extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Pour savoir si c'est Orange, Airtel, Telma, etc.
  IntColumn get operateur => intEnum<OperatorType>()();

  // Tranches de montants
  RealColumn get montantMin => real()();
  RealColumn get montantMax => real()();

  // Les frais
  RealColumn get fraisOperateur => real()();
  RealColumn get fraisClient => real()();

  // Date de dernière mise à jour
  DateTimeColumn get derniereMaj =>
      dateTime().withDefault(currentDateAndTime)();
}
