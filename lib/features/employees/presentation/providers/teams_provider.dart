import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/teams_api.dart';
import '../../data/models/team_model.dart';
import '../../../../shared/types/result.dart';

final teamsApiProvider = Provider<TeamsApi>((ref) => TeamsApi());

final teamsProvider = FutureProvider<List<TeamModel>>((ref) async {
  final api = ref.watch(teamsApiProvider);
  final result = await api.getTeams();

  switch (result) {
    case Success(:final data):
      return data;
    case Failure(:final message):
      throw Exception(message);
  }
});
