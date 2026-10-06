import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../widgets/form_scaffold.dart';
import '../widgets/reusable_form.dart';
import '../widgets/validators.dart';

class ProductFormScreen
    extends StatefulWidget {
  final int? id;

  const ProductFormScreen({
    super.key,
    this.id,
  });

  @override
  State<ProductFormScreen> createState() =>
      _ProductFormScreenState();
}

class _ProductFormScreenState
    extends State<ProductFormScreen> {
  final form =
      GlobalKey<FormState>();

  late final ProductRepository repo;
  late final BrandRepository brands;
  late final CategoryRepository categories;
  late final SupplierRepository suppliers;

  final name =
      TextEditingController();
  final sku =
      TextEditingController();
  final price =
      TextEditingController();
  final stock =
      TextEditingController();
  final description =
      TextEditingController();

  int? brandId;

  List<int> categoryIds = [];
  List<int> supplierIds = [];

  bool dirty = false;
  bool saving = false;

  String? duplicate;

  Future<PageResult<Brand>>?
      brandFuture;

  Future<PageResult<Category>>?
      categoryFuture;

  Future<PageResult<Supplier>>?
      supplierFuture;

  @override
  void initState() {
    super.initState();

    repo =
        context.read<ProductRepository>();

    brands =
        context.read<BrandRepository>();

    categories =
        context.read<CategoryRepository>();

    suppliers =
        context.read<SupplierRepository>();

    brandFuture = brands.find(
      const ListQuery(
        size: 50,
      ),
    );

    categoryFuture = categories.find(
      const ListQuery(
        size: 50,
      ),
    );

    supplierFuture = suppliers.find(
      const ListQuery(
        size: 50,
      ),
    );

    _load();
  }

  Future<void> _load() async {
    if (widget.id != null) {
      final entity =
          await repo.findById(widget.id!);

      if (entity != null) {
        name.text = entity.name;
        sku.text = entity.sku;
        price.text =
            '${entity.price}';
        stock.text =
            '${entity.stock}';
        description.text =
            entity.description;

        brandId = entity.brandId;

        categoryIds = [
          ...entity.categoryIds,
        ];

        supplierIds = [
          ...entity.supplierIds,
        ];
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _save() async {
    setState(() {
      duplicate = null;
    });

    if (!form.currentState!.validate()) {
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      if (await repo.existsBy(
        'sku',
        sku.text.trim(),
        exceptId: widget.id,
      )) {
        setState(() {
          duplicate =
              'Товар с таким SKU уже существует';
        });

        return;
      }

      final entity = Product(
        id: widget.id ?? 0,
        name: name.text.trim(),
        sku: sku.text.trim(),
        brandId: brandId!,
        categoryIds: categoryIds,
        supplierIds: supplierIds,
        price: double.parse(
          price.text.replaceAll(',', '.'),
        ),
        stock: int.parse(
          stock.text,
        ),
        description:
            description.text.trim(),
      );

      if (widget.id == null) {
        await repo.create(entity);
      } else {
        await repo.update(entity);
      }

      if (mounted) {
        dirty = false;
        context.go('/products');
      }
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    name.dispose();
    sku.dispose();
    price.dispose();
    stock.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DirtyFormScaffold(
      title: widget.id == null
          ? 'Новый товар'
          : 'Редактирование товара',
      isDirty: dirty,
      child: ReusableEntityForm(
        formKey: form,
        onSave: _save,
        saveText: saving
            ? 'Сохранение...'
            : 'Сохранить',
        fields: [
          TextFormField(
            controller: name,
            validator: (value) =>
                textLength(
              value,
              label: 'Название',
              min: 2,
              max: 120,
            ),
            onChanged: (_) =>
                setState(() => dirty = true),
            decoration:
                const InputDecoration(
              labelText: 'Название',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: sku,
            validator: (value) =>
                duplicate ??
                textLength(
                  value,
                  label: 'SKU',
                  min: 3,
                  max: 30,
                ),
            onChanged: (_) =>
                setState(() => dirty = true),
            decoration:
                const InputDecoration(
              labelText: 'SKU',
            ),
          ),
          const SizedBox(height: 14),
          FutureBuilder<PageResult<Brand>>(
            future: brandFuture,
            builder: (context, snapshot) {
              final items =
                  snapshot.data?.items ??
                      const <Brand>[];

              return DropdownButtonFormField<int>(
                value: items.any(
                  (e) => e.id == brandId,
                )
                    ? brandId
                    : null,
                decoration:
                    const InputDecoration(
                  labelText: 'Бренд',
                ),
                items: items
                    .map(
                      (e) =>
                          DropdownMenuItem<int>(
                        value: e.id,
                        child: Text(e.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    brandId = value;
                    categoryIds = [];
                    supplierIds = [];
                    dirty = true;
                  });
                },
                validator: (value) =>
                    value == null
                        ? 'Выберите бренд'
                        : null,
              );
            },
          ),
          const SizedBox(height: 14),
          _relationField<Category>(
            label: 'Категории',
            future: categoryFuture,
            selected: categoryIds,
            itemsFilter: (entity) =>
                brandId != null &&
                entity.brandId == brandId,
            onToggle: (id) {
              setState(() {
                dirty = true;

                if (categoryIds
                    .contains(id)) {
                  categoryIds.remove(id);
                } else {
                  categoryIds.add(id);
                }
              });
            },
            validator: () =>
                selectionRequired(
              categoryIds,
              label: 'Категории',
            ),
          ),
          const SizedBox(height: 14),
          _relationField<Supplier>(
            label: 'Поставщики',
            future: supplierFuture,
            selected: supplierIds,
            itemsFilter: (entity) =>
                brandId != null &&
                entity.brandId == brandId,
            onToggle: (id) {
              setState(() {
                dirty = true;

                if (supplierIds
                    .contains(id)) {
                  supplierIds.remove(id);
                } else {
                  supplierIds.add(id);
                }
              });
            },
            validator: () =>
                selectionRequired(
              supplierIds,
              label: 'Поставщики',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: price,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            validator: (value) =>
                positiveDouble(
              value,
              label: 'Цена',
            ),
            onChanged: (_) =>
                setState(() => dirty = true),
            decoration:
                const InputDecoration(
              labelText: 'Цена, €',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: stock,
            keyboardType:
                TextInputType.number,
            validator: (value) =>
                positiveInt(
              value,
              label: 'Остаток',
            ),
            onChanged: (_) =>
                setState(() => dirty = true),
            decoration:
                const InputDecoration(
              labelText: 'Остаток',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: description,
            maxLines: 4,
            validator: (value) =>
                textLength(
              value,
              label: 'Описание',
              min: 10,
              max: 400,
            ),
            onChanged: (_) =>
                setState(() => dirty = true),
            decoration:
                const InputDecoration(
              labelText: 'Описание',
            ),
          ),
          if (widget.id != null)
            Padding(
              padding:
                  const EdgeInsets.only(
                top: 12,
              ),
              child:
                  OutlinedButton.icon(
                onPressed: () async {
                  await repo.softDelete(
                    widget.id!,
                  );

                  if (mounted) {
                    context.go(
                      '/products',
                    );
                  }
                },
                icon: const Icon(
                  Icons.delete,
                ),
                label: const Text(
                  'Логически удалить',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _relationField<E>({
    required String label,
    required Future<PageResult<E>>? future,
    required List<int> selected,
    required bool Function(E) itemsFilter,
    required void Function(int) onToggle,
    required String? Function() validator,
  }) {
    return FormField<List<int>>(
      initialValue: [
        ...selected,
      ],
      validator: (_) => validator(),
      builder: (field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border:
                const OutlineInputBorder(),
            errorText: field.errorText,
          ),
          child: FutureBuilder<PageResult<E>>(
            future: future,
            builder: (context, snapshot) {
              final items =
                  snapshot.data?.items
                          .where(itemsFilter)
                          .toList() ??
                      const [];

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map(
                  (entity) {
                    final id = switch (entity) {
                      Category value =>
                        value.id,
                      Supplier value =>
                        value.id,
                      _ => 0,
                    };

                    final title =
                        switch (entity) {
                      Category value =>
                        value.name,
                      Supplier value =>
                        value.name,
                      _ => '',
                    };

                    return FilterChip(
                      label: Text(title),
                      selected:
                          selected.contains(id),
                      onSelected: (_) {
                        onToggle(id);
                        field.didChange(
                          selected,
                        );
                      },
                    );
                  },
                ).toList(),
              );
            },
          ),
        );
      },
    );
  }
}