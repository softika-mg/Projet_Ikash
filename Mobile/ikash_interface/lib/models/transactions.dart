import 'package:drift/drift.dart';
import 'profiles.dart';
import 'enum.dart';
import 'agent_numbers.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get horodatage => dateTime().withDefault(currentDateAndTime)();

  IntColumn get operateur => intEnum<OperatorType>()();
  IntColumn get type => intEnum<TransactionType>()();
  RealColumn get montant => real()();
  IntColumn get statut => intEnum<TransactionStatus>().withDefault(
    Constant(TransactionStatus.reussi.index),
  )();
  TextColumn get nomClient => text().nullable()();

  RealColumn get bonus => real().withDefault(const Constant(0.0))();
  TextColumn get numeroClient => text().nullable()();
  // On ajoute NOT NULL explicitement dans la contrainte
  TextColumn get reference => text().customConstraint('UNIQUE NOT NULL')();
  BoolColumn get estSaisieManuelle =>
      boolean().withDefault(const Constant(true))();

  // La clé étrangère vers l'agent
  IntColumn get agentId => integer().references(Profiles, #id)();
  IntColumn get agentNumberId =>
      integer().nullable().references(AgentNumbers, #id)();
}
