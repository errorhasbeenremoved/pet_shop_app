import '../models/models.dart';
import '../services/data_store.dart';

abstract class CrudRepository<T> {
  Future<PageResult<T>> find(ListQuery query);

  Future<T?> findById(int id);

  Future<T> create(T item);

  Future<T> update(T item);

  Future<void> softDelete(int id);

  Future<void> hardDelete(int id);

  Future<void> restore(int id);

  Future<int> deleteMany(List<int> ids);

  Future<bool> existsBy(
    String field,
    Object value, {
    int? exceptId,
  });
}

abstract class _BaseRepository<T>
    implements CrudRepository<T> {
  final PersistentDataStore store;
  final String entity;

  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  _BaseRepository(
    this.store,
    this.entity,
    this.fromJson,
    this.toJson,
  );

  List<T> get _items =>
      store.read(entity).map(fromJson).toList();

  Future<void> _save(List<T> items) {
    return store.write(
      entity,
      items.map(toJson).toList(),
    );
  }

  String nameOf(T item);

  List<String> searchable(T item);

  String fieldValue(
    T item,
    String field,
  );

  bool matchesFilter(
    T item,
    String? filter,
  ) {
    return filter == null ||
        filter.isEmpty ||
        true;
  }

  bool _deleted(T item) {
    return switch (item) {
      Brand e => e.isDeleted,
      Category e => e.isDeleted,
      Supplier e => e.isDeleted,
      Product e => e.isDeleted,
      Customer e => e.isDeleted,
      _ => false,
    };
  }

  int idOf(T item) {
    return switch (item) {
      Brand e => e.id,
      Category e => e.id,
      Supplier e => e.id,
      Product e => e.id,
      Customer e => e.id,
      _ => 0,
    };
  }

  T withDeleted(
    T item,
    DateTime? value,
    bool clear,
  ) {
    return switch (item) {
      Brand e => e.copyWith(
          deletedAt: value,
          clearDeletedAt: clear,
        ) as T,
      Category e => e.copyWith(
          deletedAt: value,
          clearDeletedAt: clear,
        ) as T,
      Supplier e => e.copyWith(
          deletedAt: value,
          clearDeletedAt: clear,
        ) as T,
      Product e => e.copyWith(
          deletedAt: value,
          clearDeletedAt: clear,
        ) as T,
      Customer e => e.copyWith(
          deletedAt: value,
          clearDeletedAt: clear,
        ) as T,
      _ => item,
    };
  }

  @override
  Future<PageResult<T>> find(
    ListQuery q,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 120),
    );

    var rows = _items
        .where(
          (e) => q.includeDeleted || !_deleted(e),
        )
        .toList();

    final needle =
        q.search.trim().toLowerCase();

    if (needle.isNotEmpty) {
      rows = rows
          .where(
            (e) => searchable(e).any(
              (v) => v.toLowerCase().contains(needle),
            ),
          )
          .toList();
    }

    rows = rows
        .where(
          (e) => matchesFilter(e, q.filter),
        )
        .toList();

    rows.sort(
      (a, b) {
        final result = fieldValue(
          a,
          q.sortField,
        )
            .toLowerCase()
            .compareTo(
              fieldValue(
                b,
                q.sortField,
              ).toLowerCase(),
            );

        return q.sortAscending ? result : -result;
      },
    );

    final total = rows.length;

    final from = (q.page - 1) * q.size;

    final to =
        (from + q.size) > total
            ? total
            : from + q.size;

    return PageResult<T>(
      items: from >= total
          ? <T>[]
          : rows.sublist(from, to),
      page: q.page,
      size: q.size,
      total: total,
    );
  }

  @override
  Future<T?> findById(int id) async {
    for (final item in _items) {
      if (idOf(item) == id) {
        return item;
      }
    }

    return null;
  }

  @override
  Future<T> create(T item) async {
    final rows = _items;

    final id = rows.isEmpty
        ? 1
        : rows
                .map(idOf)
                .reduce(
                  (a, b) => a > b ? a : b,
                ) +
            1;

    final created = _reId(item, id);

    rows.add(created);

    await _save(rows);

    return created;
  }

  T _reId(
    T item,
    int id,
  ) {
    return switch (item) {
      Brand e => Brand(
          id: id,
          name: e.name,
          country: e.country,
          description: e.description,
        ) as T,
      Category e => Category(
          id: id,
          name: e.name,
          brandId: e.brandId,
          description: e.description,
        ) as T,
      Supplier e => Supplier(
          id: id,
          name: e.name,
          brandId: e.brandId,
          email: e.email,
          phone: e.phone,
          description: e.description,
        ) as T,
      Product e => Product(
          id: id,
          name: e.name,
          sku: e.sku,
          brandId: e.brandId,
          categoryIds: e.categoryIds,
          supplierIds: e.supplierIds,
          price: e.price,
          stock: e.stock,
          description: e.description,
        ) as T,
      Customer e => Customer(
          id: id,
          name: e.name,
          email: e.email,
          phone: e.phone,
          card: e.card,
        ) as T,
      _ => item,
    };
  }

  @override
  Future<T> update(T item) async {
    final rows = _items;

    final index = rows.indexWhere(
      (e) => idOf(e) == idOf(item),
    );

    if (index < 0) {
      throw StateError('Запись не найдена');
    }

    rows[index] = item;

    await _save(rows);

    return item;
  }

  @override
  Future<void> softDelete(int id) async {
    final item = await findById(id);

    if (item == null) {
      throw StateError('Запись не найдена');
    }

    await update(
      withDeleted(
        item,
        DateTime.now(),
        false,
      ),
    );
  }

  @override
  Future<void> hardDelete(int id) async {
    final rows = _items
      ..removeWhere(
        (e) => idOf(e) == id,
      );

    await _save(rows);
  }

  @override
  Future<void> restore(int id) async {
    final item = await findById(id);

    if (item == null) {
      throw StateError('Запись не найдена');
    }

    await update(
      withDeleted(
        item,
        null,
        true,
      ),
    );
  }

  @override
  Future<int> deleteMany(
    List<int> ids,
  ) async {
    var count = 0;

    for (final id in ids) {
      final item = await findById(id);

      if (item != null && !_deleted(item)) {
        await softDelete(id);
        count++;
      }
    }

    return count;
  }

  @override
  Future<bool> existsBy(
    String field,
    Object value, {
    int? exceptId,
  }) async {
    for (final item in _items) {
      if (exceptId != null &&
          idOf(item) == exceptId) {
        continue;
      }

      if (fieldValue(
            item,
            field,
          ).toLowerCase() ==
          value.toString().toLowerCase()) {
        return true;
      }
    }

    return false;
  }
}

class ProductRepository
    extends _BaseRepository<Product> {
  ProductRepository(
    PersistentDataStore store,
  ) : super(
          store,
          'products',
          Product.fromJson,
          (e) => e.toJson(),
        );

  @override
  String nameOf(Product e) => e.name;

  @override
  List<String> searchable(Product e) => [
        e.name,
        e.sku,
        e.description,
      ];

  @override
  String fieldValue(
    Product e,
    String field,
  ) {
    return switch (field) {
      'price' => e.price.toString(),
      'stock' => e.stock.toString(),
      'sku' => e.sku,
      _ => e.name,
    };
  }

  @override
  bool matchesFilter(
    Product e,
    String? filter,
  ) {
    if (filter == null || filter.isEmpty) {
      return true;
    }

    final id = int.tryParse(filter);

    return e.brandId == id ||
        e.categoryIds.contains(id);
  }
}

class BrandRepository
    extends _BaseRepository<Brand> {
  BrandRepository(
    PersistentDataStore store,
  ) : super(
          store,
          'brands',
          Brand.fromJson,
          (e) => e.toJson(),
        );

  @override
  String nameOf(Brand e) => e.name;

  @override
  List<String> searchable(Brand e) => [
        e.name,
        e.country,
        e.description,
      ];

  @override
  String fieldValue(
    Brand e,
    String field,
  ) {
    return switch (field) {
      'country' => e.country,
      _ => e.name,
    };
  }

  @override
  Future<void> hardDelete(int id) async {
    final products =
        ProductRepository(store);

    final all = await products.find(
      const ListQuery(
        size: 100000,
        includeDeleted: true,
      ),
    );

    final count = all.items
        .where(
          (p) => p.brandId == id,
        )
        .length;

    if (count > 0) {
      throw StateError(
        'Нельзя удалить бренд: на него ссылаются $count товар(ов)',
      );
    }

    await super.hardDelete(id);
  }
}

class CategoryRepository
    extends _BaseRepository<Category> {
  CategoryRepository(
    PersistentDataStore store,
  ) : super(
          store,
          'categories',
          Category.fromJson,
          (e) => e.toJson(),
        );

  @override
  String nameOf(Category e) => e.name;

  @override
  List<String> searchable(Category e) => [
        e.name,
        e.description,
      ];

  @override
  String fieldValue(
    Category e,
    String field,
  ) {
    return switch (field) {
      'brandId' => e.brandId.toString(),
      _ => e.name,
    };
  }

  @override
  bool matchesFilter(
    Category e,
    String? filter,
  ) {
    return filter == null ||
        filter.isEmpty ||
        e.brandId == int.tryParse(filter);
  }
}

class SupplierRepository
    extends _BaseRepository<Supplier> {
  SupplierRepository(
    PersistentDataStore store,
  ) : super(
          store,
          'suppliers',
          Supplier.fromJson,
          (e) => e.toJson(),
        );

  @override
  String nameOf(Supplier e) => e.name;

  @override
  List<String> searchable(Supplier e) => [
        e.name,
        e.email,
        e.phone,
        e.description,
      ];

  @override
  String fieldValue(
    Supplier e,
    String field,
  ) {
    return switch (field) {
      'email' => e.email,
      'brandId' => e.brandId.toString(),
      _ => e.name,
    };
  }

  @override
  bool matchesFilter(
    Supplier e,
    String? filter,
  ) {
    return filter == null ||
        filter.isEmpty ||
        e.brandId == int.tryParse(filter);
  }
}

class CustomerRepository
    extends _BaseRepository<Customer> {
  CustomerRepository(
    PersistentDataStore store,
  ) : super(
          store,
          'customers',
          Customer.fromJson,
          (e) => e.toJson(),
        );

  @override
  String nameOf(Customer e) => e.name;

  @override
  List<String> searchable(Customer e) => [
        e.name,
        e.email,
        e.phone,
        e.card.number,
      ];

  @override
  String fieldValue(
    Customer e,
    String field,
  ) {
    return switch (field) {
      'email' => e.email,
      'points' => e.card.bonusPoints.toString(),
      _ => e.name,
    };
  }
}