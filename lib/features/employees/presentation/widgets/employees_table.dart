import 'package:flutter/material.dart';
import '../../data/models/employee_model.dart';

class EmployeesTable extends StatefulWidget {
  final List<EmployeeModel> employees;

  const EmployeesTable({super.key, required this.employees});

  @override
  State<EmployeesTable> createState() => _EmployeesTableState();
}

class _EmployeesTableState extends State<EmployeesTable> {
  late List<EmployeeModel> _sortedEmployees;
  String? _sortColumn;
  bool _ascending = true;

  final ScrollController _horizontalScroll = ScrollController();
  final ScrollController _verticalScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _sortedEmployees = [...widget.employees];
  }

  @override
  void didUpdateWidget(covariant EmployeesTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.employees != widget.employees) {
      _sortedEmployees = [...widget.employees];
      if (_sortColumn != null) _sortEmployees();
    }
  }

  @override
  void dispose() {
    _horizontalScroll.dispose();
    _verticalScroll.dispose();
    super.dispose();
  }

  void _sortBy(String column) {
    setState(() {
      if (_sortColumn == column) {
        _ascending = !_ascending;
      } else {
        _sortColumn = column;
        _ascending = true;
      }
      _sortEmployees();
    });
  }

  void _sortEmployees() {
    _sortedEmployees.sort((a, b) {
      final aVal = _getFieldValue(a, _sortColumn!) ?? '';
      final bVal = _getFieldValue(b, _sortColumn!) ?? '';
      return _ascending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
    });
  }

  String? _getFieldValue(EmployeeModel e, String field) {
    switch (field) {
      case 'lastName':
        return e.lastName;
      case 'firstName':
        return e.firstName;
      case 'middleName':
        return e.middleName ?? '';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _horizontalScroll,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontalScroll,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 1200),
          child: SizedBox(
            height: 400, // ограничение по высоте
            child: Scrollbar(
              controller: _verticalScroll,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _verticalScroll,
                scrollDirection: Axis.vertical,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                  sortColumnIndex: _sortColumn == null
                      ? null
                      : ['lastName', 'firstName', 'middleName'].indexOf(_sortColumn!),
                  sortAscending: _ascending,
                  columns: [
                    DataColumn(
                      label: const Text('Фамилия'),
                      onSort: (_, __) => _sortBy('lastName'),
                    ),
                    DataColumn(
                      label: const Text('Имя'),
                      onSort: (_, __) => _sortBy('firstName'),
                    ),
                    DataColumn(
                      label: const Text('Отчество'),
                      onSort: (_, __) => _sortBy('middleName'),
                    ),
                    const DataColumn(label: Text('Команда')),
                    const DataColumn(label: Text('Должность')),
                    const DataColumn(label: Text('Почта')),
                  ],
                  rows: _sortedEmployees.map((e) {
                    return DataRow(cells: [
                      DataCell(Text(e.lastName)),
                      DataCell(Text(e.firstName)),
                      DataCell(Text(e.middleName ?? '')),
                      DataCell(Text(e.team ?? '-')),
                      DataCell(Text(e.position ?? '-')),
                      DataCell(Text(e.email)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
