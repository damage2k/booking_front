import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/teams_provider.dart';
import '../providers/employees_filter_provider.dart';

class EmployeesFilterRow extends ConsumerStatefulWidget {
  const EmployeesFilterRow({super.key});

  @override
  ConsumerState<EmployeesFilterRow> createState() => _EmployeesFilterRowState();
}

class _EmployeesFilterRowState extends ConsumerState<EmployeesFilterRow> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedTeam;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final text = _searchController.text.trim();
    ref.read(searchTextProvider.notifier).state = text;
    ref.read(selectedTeamProvider.notifier).state = _selectedTeam;
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() => _selectedTeam = null);

    ref.read(searchTextProvider.notifier).state = '';
    ref.read(selectedTeamProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final teamsAsync = ref.watch(teamsProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    final searchField = Expanded(
      flex: 2,
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Поиск по ФИО или команде',
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );

    final findButton = Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          onPressed: _applyFilters,
          child: const Text('Найти'),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: _clearFilters,
          child: const Text('Очистить фильтр'),
        ),
      ],
    );

    final teamDropdown = Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Material(
          type: MaterialType.transparency,
          child: teamsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (e, _) => Text('Ошибка: $e'),
            data: (teams) => DropdownButtonFormField<String>(
              isDense: true,
              isExpanded: false,
              value: _selectedTeam,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              hint: const Text('Команда'),
              items: teams
                  .map((team) => DropdownMenuItem<String>(
                value: team.name,
                child: Text(team.name),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedTeam = value),
            ),
          ),
        ),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Поиск по ФИО или команде',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),
          teamDropdown,
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            onPressed: _applyFilters,
            child: const Text('Найти'),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Очистить фильтр'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            searchField,
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onPressed: _applyFilters,
              child: const Text('Найти'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: _clearFilters,
          child: const Text('Очистить фильтр'),
        ),
        const SizedBox(height: 12),
        teamDropdown,
      ],
    );

  }
}

