import 'package:flutter/material.dart';

class TableColumnSpec<T> {
  final String label;
  final String? sortField;
  final bool numeric;
  final Widget Function(T item) build;

  const TableColumnSpec({
    required this.label,
    required this.build,
    this.sortField,
    this.numeric = false,
  });
}

class EntityTable<T>
    extends StatelessWidget {
  final List<TableColumnSpec<T>> columns;
  final List<T> items;
  final int Function(T) idOf;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final String? sortField;
  final bool sortAscending;
  final void Function(String)? onSort;
  final List<Widget> Function(T)? actions;

  const EntityTable({
    super.key,
    required this.columns,
    required this.items,
    required this.idOf,
    this.selected = const {},
    this.onToggleSelect,
    this.sortField,
    this.sortAscending = true,
    this.onSort,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final dataColumns =
        <DataColumn>[
      if (onToggleSelect != null)
        const DataColumn(
          label: Text(''),
        ),
      ...columns.map(
        (column) => DataColumn(
          label: Text(column.label),
          numeric: column.numeric,
          onSort:
              column.sortField != null &&
                      onSort != null
                  ? (_, __) =>
                      onSort!(column.sortField!)
                  : null,
        ),
      ),
      if (actions != null)
        const DataColumn(
          label: Text('Действия'),
        ),
    ];

    final rows = items.map(
      (item) {
        return DataRow(
          selected:
              selected.contains(idOf(item)),
          cells: [
            if (onToggleSelect != null)
              DataCell(
                Checkbox(
                  value: selected.contains(
                    idOf(item),
                  ),
                  onChanged: (_) =>
                      onToggleSelect!(
                    idOf(item),
                  ),
                ),
              ),
            ...columns.map(
              (column) => DataCell(
                column.build(item),
              ),
            ),
            if (actions != null)
              DataCell(
                Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: actions!(item),
                ),
              ),
          ],
        );
      },
    ).toList();

    final sortIndex =
        columns.indexWhere(
      (column) =>
          column.sortField == sortField,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex:
            sortIndex < 0
                ? null
                : onToggleSelect != null
                    ? sortIndex + 1
                    : sortIndex,
        sortAscending: sortAscending,
        columns: dataColumns,
        rows: rows,
      ),
    );
  }
}