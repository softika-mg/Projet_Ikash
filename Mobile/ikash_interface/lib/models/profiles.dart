import 'package:drift/drift.dart';
import 'enum.dart';

class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nom => text()();
  IntColumn get role =>
      intEnum<RoleType>().withDefault(Constant(RoleType.agent.index))();
  TextColumn get codePin => text().nullable()();
  RealColumn get soldeCourant => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Lien vers l'admin (Self-reference)
  IntColumn get adminId => integer().nullable().references(Profiles, #id)();
}
