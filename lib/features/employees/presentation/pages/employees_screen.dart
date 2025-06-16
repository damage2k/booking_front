import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/employees_provider.dart';
import '../providers/employees_filter_provider.dart';
import '../widgets/create_employee_dialog.dart';
import '../widgets/employees_filter_row.dart';
import '../widgets/employees_table.dart';



class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  @override


  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(filteredEmployeesProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Сотрудники',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const CreateEmployeeDialog(),
                );
              },
              child: const Text('Создать'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const EmployeesFilterRow(),
        const SizedBox(height: 16),
        employeesAsync.when(
          loading: () => ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 1200),
              child: Center(child: CircularProgressIndicator())
          ),
          error: (e, _) => Center(child: Text('Ошибка: $e')),
          data: (employees) => EmployeesTable(employees: employees),
        ),
        const SizedBox(height: 16),
      ],
    );

    return Scaffold(
      backgroundColor: isMobile ? null : Colors.grey.shade200,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isMobile) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SafeArea(child: content),
            );
          }

          return Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 32),
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 64,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IntrinsicWidth(
                stepWidth: 56,
                child: SafeArea(child: content),
              ),
            ),
          );
        },
      ),
    );
  }
}
