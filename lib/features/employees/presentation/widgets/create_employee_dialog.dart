import 'package:booking_front/shared/ui/generic_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/types/result.dart';
import '../../../../shared/utils/email_validator.dart';
import '../providers/employees_filter_provider.dart';
import '../providers/employees_provider.dart';
import '../providers/teams_provider.dart';

class CreateEmployeeDialog extends ConsumerStatefulWidget {
  const CreateEmployeeDialog({super.key});

  @override
  ConsumerState<CreateEmployeeDialog> createState() => _CreateEmployeeDialogState();
}

class _CreateEmployeeDialogState extends ConsumerState<CreateEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();

  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();

  int? _selectedTeamId;
  String? _selectedPosition; // пока как строка

  final _mockPositions = <Map<String, String>>[
    {"id": "1", "label": "Разработчик"},
    {"id": "2", "label": "Дизайнер"},
    {"id": "3", "label": "Аналитик"},
  ];

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() != true) return;

    final api = ref.read(employeesApiProvider);
    final result = await api.createEmployee(
      username: _usernameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      middleName: _middleNameController.text.trim().isEmpty
          ? null
          : _middleNameController.text.trim(),
      teamId: _selectedTeamId,
      positionId: _selectedPosition,
    );

    switch (result) {
      case Success():
        await ref.refresh(employeesProvider.future);
        await ref.refresh(filteredEmployeesProvider.future);

        ref.invalidate(searchTextProvider);
        ref.invalidate(selectedTeamProvider);

        if (mounted) {

          Navigator.of(context).pop();

          showDialog(
            context: context,
            builder: (_) => const GenericSuccessDialog(
              title: 'Успешно',
              message: 'Сотрудник создан',
            ),
          );
        }
      case Failure(:final message):
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Ошибка'),
              content: Text(message),
            ),
          );
        }
    }
  }


  @override
  Widget build(BuildContext context) {
    final teamsAsync = ref.watch(teamsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Создание сотрудника',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Имя пользователя *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Обязательное поле' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Фамилия *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Обязательное поле' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Имя *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Обязательное поле' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _middleNameController,
                  decoration: const InputDecoration(
                    labelText: 'Отчество',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || !EmailValidator.isValid(value)
                      ? 'Некорректный email'
                      : null,
                ),
                const SizedBox(height: 12),
                teamsAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Ошибка: $e'),
                  data: (teams) => DropdownButtonFormField<int>(
                    value: _selectedTeamId,
                    decoration: const InputDecoration(
                      labelText: 'Команда',
                      border: OutlineInputBorder(),
                    ),
                    items: teams
                        .map((team) => DropdownMenuItem(
                      value: team.id,
                      child: Text(team.name),
                    ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedTeamId = value),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedPosition,
                  decoration: const InputDecoration(
                    labelText: 'Должность',
                    border: OutlineInputBorder(),
                  ),
                  items: _mockPositions
                      .map((pos) => DropdownMenuItem(
                    value: pos["id"],
                    child: Text(pos["label"] ?? ""),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedPosition = value),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Создать'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
