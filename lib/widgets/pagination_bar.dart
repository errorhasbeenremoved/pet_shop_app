import 'package:flutter/material.dart';

class PaginationBar
    extends StatelessWidget {
  final int page;
  final int totalPages;
  final int total;
  final int size;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onSizeChanged;

  const PaginationBar({
    super.key,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.size,
    required this.onPageChanged,
    required this.onSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeTotalPages =
        totalPages < 1 ? 1 : totalPages;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment:
          WrapCrossAlignment.center,
      children: [
        Text(
          'Страница $page из $safeTotalPages · $total записей',
        ),
        IconButton(
          onPressed: page > 1
              ? () => onPageChanged(1)
              : null,
          icon: const Icon(
            Icons.first_page,
          ),
        ),
        IconButton(
          onPressed: page > 1
              ? () => onPageChanged(page - 1)
              : null,
          icon: const Icon(
            Icons.chevron_left,
          ),
        ),
        IconButton(
          onPressed:
              page < safeTotalPages
                  ? () =>
                      onPageChanged(page + 1)
                  : null,
          icon: const Icon(
            Icons.chevron_right,
          ),
        ),
        IconButton(
          onPressed:
              page < safeTotalPages
                  ? () =>
                      onPageChanged(
                        safeTotalPages,
                      )
                  : null,
          icon: const Icon(
            Icons.last_page,
          ),
        ),
        DropdownButton<int>(
          value: size,
          items: const [
            DropdownMenuItem(
              value: 10,
              child: Text('10'),
            ),
            DropdownMenuItem(
              value: 25,
              child: Text('25'),
            ),
            DropdownMenuItem(
              value: 50,
              child: Text('50'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onSizeChanged(value);
            }
          },
        ),
      ],
    );
  }
}