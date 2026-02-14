import 'package:drift/drift.dart';
import 'profiles.dart';

class LogActivities extends Table {
  IntColumn get id => integer().autoIncrement()();

  // On donne un nom unique à chaque relation
  @ReferenceName("logsAsAdmin")
  IntColumn get adminId => integer().nullable().references(Profiles, #id)();

  @ReferenceName("logsAsAgent")
  IntColumn get agentId => integer().nullable().references(Profiles, #id)();

  TextColumn get action => text()();
  RealColumn get ancienSolde => real().nullable()();
  RealColumn get nouveauSolde => real().nullable()();
  DateTimeColumn get horodatage => dateTime().withDefault(currentDateAndTime)();
}
