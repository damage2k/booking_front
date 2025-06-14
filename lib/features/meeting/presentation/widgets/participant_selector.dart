import 'package:booking_front/features/auth/presentation/providers/auth_providers.dart';
import 'package:booking_front/features/meeting/domain/participant.dart';
import 'package:booking_front/features/meeting/presentation/providers/participants_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParticipantSelector extends ConsumerStatefulWidget {
  final List<Participant> selected;
  final void Function(List<Participant>) onChanged;

  const ParticipantSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  ConsumerState<ParticipantSelector> createState() => _ParticipantSelectorState();
}

class _ParticipantSelectorState extends ConsumerState<ParticipantSelector> {
  final fieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(participantQueryProvider.notifier).state = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider);
    final query = ref.watch(participantQueryProvider);
    final searchAsync = ref.watch(participantSearchProvider);

    return Column(
      children: [
        if (widget.selected.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.selected.map((p) {
                  final fullName =
                      '${p.lastName} ${p.firstName}${p.middleName != null ? ' ${p.middleName}' : ''}';
                  return Chip(
                    label: Text(fullName),
                    onDeleted: () {
                      final updated = [...widget.selected]..remove(p);
                      widget.onChanged(updated);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        const SizedBox(height: 16),
        TextFormField(
          key: fieldKey,
          decoration: InputDecoration(
            labelText: 'Введите фамилию',
            border: const OutlineInputBorder(),
            suffixIcon: query.isNotEmpty && searchAsync.isLoading
                ? const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : null,
          ),
          onChanged: (val) =>
          ref.read(participantQueryProvider.notifier).state = val,
        ),
        const SizedBox(height: 16),
        if (query.isNotEmpty)
          searchAsync.when(
            loading: () => const SizedBox(),
            error: (e, _) => Text('Ошибка: $e'),
            data: (users) {
              final filtered = users.where((u) => u.id != currentUser?.id).toList();

              if (filtered.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Нет сотрудника с такой фамилией'),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final u = filtered[index];
                    final fullName =
                        '${u.lastName} ${u.firstName}${u.middleName != null ? ' ${u.middleName}' : ''}';

                    return ListTile(
                      title: Text(fullName),
                      onTap: () {
                        final updated = [
                          ...widget.selected,
                          Participant(
                            username: u.username,
                            firstName: u.firstName,
                            lastName: u.lastName,
                            middleName: u.middleName,
                            avatar: u.avatar,
                          )
                        ];
                        widget.onChanged(updated);
                        ref.read(participantQueryProvider.notifier).state = '';
                      },
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
