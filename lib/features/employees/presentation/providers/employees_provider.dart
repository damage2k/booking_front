import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../employees/data/datasources/employees_api.dart';
import '../../../employees/data/models/employee_model.dart';
import '../../../../shared/types/result.dart';

final employeesApiProvider = Provider<EmployeesApi>((ref) => EmployeesApi());

final employeesProvider =
FutureProvider<List<EmployeeModel>>((ref) async {
  final api = ref.watch(employeesApiProvider);
  final result = await api.getEmployees();

  switch (result) {
    case Success(:final data):
      return data;
    case Failure(:final message):
      throw Exception(message);
  }
});
