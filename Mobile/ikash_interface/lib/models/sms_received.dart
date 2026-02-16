import 'package:drift/drift.dart';
import 'enum.dart';

class SmsReceived extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rawBody => text()(); // Le texte brut du SMS pour preuve
  TextColumn get sender => text()(); // "Mvola", "OrangeMoney", etc.

  // Données extraites par l'engine
  IntColumn get operateur => intEnum<OperatorType>()();
  IntColumn get type => intEnum<TransactionType>()();
  RealColumn get montant => real()();
  TextColumn get reference => text().customConstraint('UNIQUE NOT NULL')();
  TextColumn get numeroClient => text().nullable()();

  DateTimeColumn get dateReception =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get estTraite => boolean().withDefault(const Constant(false))();
}
