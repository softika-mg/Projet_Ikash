import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../services/auth_service.dart';

// On suppose que l'ID de l'agent actuel est récupéré via un autre provider (ex: authProvider)
final agentNumbersStreamProvider =
    StreamProvider.family<List<AgentNumber>, int>((ref, agentId) {
      final db = ref.watch(databaseProvider);
      return db.watchAgentNumbers(agentId);
    });
