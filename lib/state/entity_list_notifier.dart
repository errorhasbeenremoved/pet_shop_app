import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class EntityListNotifier<T> extends ChangeNotifier {
  final CrudRepository<T> repository;

  ListQuery query;

  PageResult<T> result = PageResult<T>(
    items: const [],
    page: 1,
    size: 10,
    total: 0,
  );

  bool loading = true;
  String? error;

  final Set<int> selected = {};

  EntityListNotifier(
    this.repository, {
    ListQuery? initialQuery,
  }) : query = initialQuery ?? const ListQuery();

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      result = await repository.find(query);
    } catch (e) {
      error = 'Ошибка загрузки: $e';
    }

    loading = false;
    notifyListeners();
  }

  Future<void> apply(
    ListQuery next,
  ) async {
    query = next;
    selected.clear();
    await load();
  }

  void toggle(int id) {
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }

    notifyListeners();
  }

  Future<void> softDelete(int id) async {
    await repository.softDelete(id);
    await load();
  }

  Future<void> hardDelete(int id) async {
    await repository.hardDelete(id);
    await load();
  }

  Future<void> restore(int id) async {
    await repository.restore(id);
    await load();
  }

  Future<void> deleteSelected() async {
    for (final id in selected) {
      await repository.softDelete(id);
    }

    selected.clear();

    await load();
  }
}