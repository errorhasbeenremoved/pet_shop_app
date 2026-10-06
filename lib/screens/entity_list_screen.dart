import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/responsive_card_list.dart';

typedef RepoBuilder<T> = CrudRepository<T> Function(BuildContext context);

typedef ColumnsBuilder<T> = List<TableColumnSpec<T>> Function(BuildContext context);
typedef CardBuilder<T> = Widget Function(BuildContext context, T item);
typedef ActionsBuilder<T> = List<Widget> Function(BuildContext context, T item, EntityListNotifier<T> notifier);

class EntityListScreen<T> extends StatefulWidget {
  final RepoBuilder<T> repoBuilder;
  final String title;
  final String path;
  final ListQuery initialQuery;
  final ColumnsBuilder<T> columns;
  final CardBuilder<T> card;
  final int Function(T item) idOf;
  final ActionsBuilder<T> actions;
  final Widget Function(BuildContext, ListQuery)? filterBuilder;

  const EntityListScreen({
    super.key,
    required this.repoBuilder,
    required this.title,
    required this.path,
    required this.initialQuery,
    required this.columns,
    required this.card,
    required this.idOf,
    required this.actions,
    this.filterBuilder,
  });

  static Widget product({required ListQuery initialQuery}) => EntityListScreen<Product>(
        repoBuilder: (c) => c.read<ProductRepository>(),
        title: 'Товары',
        path: '/products',
        initialQuery: initialQuery,
        columns: (_) => [
          TableColumnSpec(label: 'Название', sortField: 'name', build: (e) => Text(e.name)),
          TableColumnSpec(label: 'SKU', sortField: 'sku', build: (e) => Text(e.sku)),
          TableColumnSpec(label: 'Бренд', build: (e) => Text('${e.brandId}')),
          TableColumnSpec(label: 'Цена', sortField: 'price', numeric: true, build: (e) => Text('${e.price.toStringAsFixed(2)} €')),
          TableColumnSpec(label: 'Остаток', sortField: 'stock', numeric: true, build: (e) => Text('${e.stock}')),
        ],
        card: (_, e) => _card(e.name, 'SKU: ${e.sku}', '${e.price.toStringAsFixed(2)} € · остаток ${e.stock}', e.isDeleted),
        idOf: (e) => e.id,
        actions: (c, e, n) => _actions(c, '/products/${e.id}/edit', e.isDeleted, n, e.id),
        filterBuilder: (c, q) => FutureBuilder<PageResult<Brand>>(future:c.read<BrandRepository>().find(const ListQuery(size:50)),builder:(c,s){final items=s.data?.items??const <Brand>[];return DropdownButton<String?>(value:q.filter,hint:const Text('Фильтр бренда'),items:[const DropdownMenuItem<String?>(value:null,child:Text('Все бренды')),...items.map((e)=>DropdownMenuItem<String?>(value:'${e.id}',child:Text(e.name)))],onChanged:(v){final state=c.findAncestorStateOfType<_EntityListScreenState<Product>>();state?.apply(q.copyWith(filter:v));});}),
      );

  static Widget brand({required ListQuery initialQuery}) => EntityListScreen<Brand>(
        repoBuilder: (c) => c.read<BrandRepository>(),
        title: 'Бренды',
        path: '/brands',
        initialQuery: initialQuery,
        columns: (_) => [
          TableColumnSpec(label: 'Название', sortField: 'name', build: (e) => Text(e.name)),
          TableColumnSpec(label: 'Страна', sortField: 'country', build: (e) => Text(e.country)),
          TableColumnSpec(label: 'Описание', build: (e) => Text(e.description)),
        ],
        card: (_, e) => _card(e.name, e.country, e.description, e.isDeleted),
        idOf: (e) => e.id,
        actions: (c, e, n) => _actions(c, '/brands/${e.id}/edit', e.isDeleted, n, e.id),
      );

  static Widget category({required ListQuery initialQuery}) => EntityListScreen<Category>(
        repoBuilder: (c) => c.read<CategoryRepository>(),
        title: 'Категории',
        path: '/categories',
        initialQuery: initialQuery,
        columns: (_) => [
          TableColumnSpec(label: 'Название', sortField: 'name', build: (e) => Text(e.name)),
          TableColumnSpec(label: 'Бренд', sortField: 'brandId', build: (e) => Text('${e.brandId}')),
          TableColumnSpec(label: 'Описание', build: (e) => Text(e.description)),
        ],
        card: (_, e) => _card(e.name, 'Бренд #${e.brandId}', e.description, e.isDeleted),
        idOf: (e) => e.id,
        actions: (c, e, n) => _actions(c, '/categories/${e.id}/edit', e.isDeleted, n, e.id),
        filterBuilder: (c, q) => FutureBuilder<PageResult<Brand>>(future:c.read<BrandRepository>().find(const ListQuery(size:50)),builder:(c,s){final items=s.data?.items??const <Brand>[];return DropdownButton<String?>(value:q.filter,hint:const Text('Фильтр бренда'),items:[const DropdownMenuItem<String?>(value:null,child:Text('Все бренды')),...items.map((e)=>DropdownMenuItem<String?>(value:'${e.id}',child:Text(e.name)))],onChanged:(v){final state=c.findAncestorStateOfType<_EntityListScreenState<Category>>();state?.apply(q.copyWith(filter:v));});}),
      );

  static Widget supplier({required ListQuery initialQuery}) => EntityListScreen<Supplier>(
        repoBuilder: (c) => c.read<SupplierRepository>(),
        title: 'Поставщики',
        path: '/suppliers',
        initialQuery: initialQuery,
        columns: (_) => [
          TableColumnSpec(label: 'Название', sortField: 'name', build: (e) => Text(e.name)),
          TableColumnSpec(label: 'Email', sortField: 'email', build: (e) => Text(e.email)),
          TableColumnSpec(label: 'Телефон', build: (e) => Text(e.phone)),
        ],
        card: (_, e) => _card(e.name, e.email, e.phone, e.isDeleted),
        idOf: (e) => e.id,
        actions: (c, e, n) => _actions(c, '/suppliers/${e.id}/edit', e.isDeleted, n, e.id),
        filterBuilder: (c, q) => FutureBuilder<PageResult<Brand>>(future:c.read<BrandRepository>().find(const ListQuery(size:50)),builder:(c,s){final items=s.data?.items??const <Brand>[];return DropdownButton<String?>(value:q.filter,hint:const Text('Фильтр бренда'),items:[const DropdownMenuItem<String?>(value:null,child:Text('Все бренды')),...items.map((e)=>DropdownMenuItem<String?>(value:'${e.id}',child:Text(e.name)))],onChanged:(v){final state=c.findAncestorStateOfType<_EntityListScreenState<Supplier>>();state?.apply(q.copyWith(filter:v));});}),
      );

  static Widget customer({required ListQuery initialQuery}) => EntityListScreen<Customer>(
        repoBuilder: (c) => c.read<CustomerRepository>(),
        title: 'Клиенты',
        path: '/customers',
        initialQuery: initialQuery,
        columns: (_) => [
          TableColumnSpec(label: 'Имя', sortField: 'name', build: (e) => Text(e.name)),
          TableColumnSpec(label: 'Email', sortField: 'email', build: (e) => Text(e.email)),
          TableColumnSpec(label: 'Карта', build: (e) => Text(e.card.number)),
          TableColumnSpec(label: 'Баллы', sortField: 'points', numeric: true, build: (e) => Text('${e.card.bonusPoints}')),
        ],
        card: (_, e) => _card(e.name, e.email, 'Карта: ${e.card.number} · ${e.card.level}', e.isDeleted),
        idOf: (e) => e.id,
        actions: (c, e, n) => _actions(c, '/customers/${e.id}/edit', e.isDeleted, n, e.id),
      );

  @override
  State<EntityListScreen<T>> createState() => _EntityListScreenState<T>();
}

class _EntityListScreenState<T> extends State<EntityListScreen<T>> {
  late final EntityListNotifier<T> notifier;
  late final TextEditingController search;

  @override
  void initState() {
    super.initState();
    notifier = EntityListNotifier<T>(widget.repoBuilder(context), initialQuery: widget.initialQuery)..load();
    search = TextEditingController(text: widget.initialQuery.search);
  }

  @override
  void dispose() {
    search.dispose();
    notifier.dispose();
    super.dispose();
  }

  void apply(ListQuery q) {
    notifier.apply(q);
    final uri = q.toUri(widget.path);
    if (mounted && GoRouterState.of(context).uri.toString() != uri.toString()) {
      context.go(uri.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: notifier,
      child: Consumer<EntityListNotifier<T>>(
        builder: (context, n, _) => Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              IconButton(onPressed: () => context.go('/'), icon: const Icon(Icons.home)),
              IconButton(onPressed: () => context.go('${widget.path}/new'), icon: const Icon(Icons.add)),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: search,
                        decoration: const InputDecoration(labelText: 'Поиск', prefixIcon: Icon(Icons.search)),
                        onChanged: (value) {
                          Future.delayed(const Duration(milliseconds: 350), () {
                            if (mounted && value == search.text) apply(n.query.copyWith(search: value));
                          });
                        },
                      ),
                    ),
                    if (widget.filterBuilder != null) widget.filterBuilder!(context, n.query),
                    FilterChip(
                      label: const Text('Показывать удалённые'),
                      selected: n.query.includeDeleted,
                      onSelected: (value) => apply(n.query.copyWith(includeDeleted: value)),
                    ),
                    if (n.selected.isNotEmpty)
                      FilledButton.tonalIcon(
                        onPressed: () async {
                          final ok = await _confirm(context, 'Удалить выбранные записи?', 'Записи будут логически удалены.');
                          if (ok) await n.deleteSelected();
                        },
                        icon: const Icon(Icons.delete_sweep),
                        label: Text('Удалить выбранные (${n.selected.length})'),
                      ),
                    OutlinedButton(onPressed: () => context.go('${widget.path}/new'), child: const Text('Добавить')),
                  ],
                ),
              ),
              if (n.error != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(n.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              Expanded(
                child: n.loading
                    ? const Center(child: CircularProgressIndicator())
                    : n.result.items.isEmpty
                        ? const Center(child: Text('Нет данных'))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 600) {
                                return ResponsiveCardList(items: n.result.items, itemBuilder: (item) => widget.card(context, item));
                              }
                              return EntityTable(
                                columns: widget.columns(context),
                                items: n.result.items,
                                idOf: widget.idOf,
                                selected: n.selected,
                                onToggleSelect: n.toggle,
                                sortField: n.query.sortField,
                                sortAscending: n.query.sortAscending,
                                onSort: (field) => apply(n.query.copyWith(
                                  sortField: field,
                                  sortAscending: n.query.sortField == field ? !n.query.sortAscending : true,
                                )),
                                actions: (item) => widget.actions(context, item, n),
                              );
                            },
                          ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: PaginationBar(
                  page: n.result.page,
                  totalPages: n.result.totalPages,
                  total: n.result.total,
                  size: n.result.size,
                  onPageChanged: (page) => apply(n.query.copyWith(page: page)),
                  onSizeChanged: (size) => apply(n.query.copyWith(size: size)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _card(String title, String line1, String line2, bool deleted) => Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text('$line1\n$line2'),
        isThreeLine: true,
        trailing: deleted ? const Icon(Icons.delete_outline) : null,
      ),
    );

List<Widget> _actions<T>(BuildContext context, String editPath, bool deleted, EntityListNotifier<T> notifier, int id) => [
      IconButton(onPressed: () => context.go(editPath), icon: const Icon(Icons.edit)),
      IconButton(
        tooltip: deleted ? 'Восстановить' : 'Удалить',
        onPressed: () => deleted ? notifier.restore(id) : notifier.softDelete(id),
        icon: Icon(deleted ? Icons.restore : Icons.delete_outline),
      ),
      if (deleted)
        IconButton(
          tooltip: 'Физически удалить',
          onPressed: () async {
            final ok = await _confirm(context, 'Физически удалить?', 'Запись нельзя будет восстановить.');
            if (!ok) return;
            try {
              await notifier.hardDelete(id);
            } catch (e) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
            }
          },
          icon: const Icon(Icons.delete_forever),
        ),
    ];

Future<bool> _confirm(BuildContext context, String title, String message) async =>
    await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Продолжить')),
            ],
          ),
        ) ??
        false;
