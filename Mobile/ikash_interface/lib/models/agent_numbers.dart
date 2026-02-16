import 'package:drift/drift.dart';
import 'profiles.dart';
import 'enum.dart';

class AgentNumbers extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Lien vers le profil de l'agent
  IntColumn get profileId => integer().references(Profiles, #id)();

  // Quel opérateur (Enum que tu as déjà)
  IntColumn get operateur => intEnum<OperatorType>()();

  // Le numéro de téléphone de la puce
  TextColumn get numeroPuce => text()();

  // Le solde actuel de cette puce précise
  RealColumn get soldePuce => real().withDefault(const Constant(0.0))();
}
