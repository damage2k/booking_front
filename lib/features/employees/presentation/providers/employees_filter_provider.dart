import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/types/result.dart';
import '../../data/models/employee_model.dart';
import 'employees_provider.dart';

final searchTextProvider = StateProvider<String>((ref) => '');
final selectedTeamProvider = StateProvider<String?>((ref) => null);

final filteredEmployeesProvider = FutureProvider<List<EmployeeModel>>((ref) async {
  final api = ref.watch(employeesApiProvider);
  final result = await api.getEmployees();

  final search = ref.watch(searchTextProvider).trim().toLowerCase();
  final selectedTeam = ref.watch(selectedTeamProvider);

  switch (result) {
    case Success(:final data):
      return data.where((e) {
        final fullName =
        '${e.lastName} ${e.firstName} ${e.middleName ?? ''}'.toLowerCase();
        final matchesText = search.isEmpty || fullName.contains(search) || (e.team ?? '').toLowerCase().contains(search);
        final matchesTeam = selectedTeam == null || e.team == selectedTeam;
        return matchesText && matchesTeam;
      }).toList();

    case Failure(:final message):
      throw Exception(message);
  }
});

