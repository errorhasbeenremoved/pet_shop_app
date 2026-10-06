import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../widgets/form_scaffold.dart';
import '../widgets/reusable_form.dart';
import '../widgets/validators.dart';

class CategoryFormScreen
    extends StatefulWidget {
  final int? id;

  const CategoryFormScreen({
    super.key,
    this.id,
  });

  @override
  State<CategoryFormScreen> createState() =>
      _CategoryFormScreenState();
}

class _CategoryFormScreenState
    extends State<CategoryFormScreen> {
  final form =
      GlobalKey<FormState>();

  late final CategoryRepository repo;
  late final BrandRepository brands;

  final name =
      TextEditingController();
  final description =
      TextEditingController();

  int? brandId;

  bool dirty = false;
  bool saving = false;

  Future<PageResult<Brand>>?
      brandFuture;

  @override
  void initState() {
    super.initState();

    repo =
        context.read<CategoryRepository>();

    brands =
        context.read<BrandRepository>();

    brandFuture =
        brands.find(
      const ListQuery(),
    );

    _load();
  }

  Future<void> _load() async {
    if (widget.id != null) {
      final entity =
          await repo.findById(widget.id!);

      if (entity != null) {
        name.text = entity.name;
        description.text =
            entity.description;
        brandId = entity.brandId;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _save() async {
    if (!form.currentState!.validate()) {
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final entity = Category(
        id: widget.id ?? 0,
        name: name.text.trim(),
        brandId: brandId!,
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
        context.go('/categories');
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
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DirtyFormScaffold(
      title: widget.id == null
          ? 'Новая категория'
          : 'Редактирование категории',
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
              max: 80,
            ),
            onChanged: (_) =>
                setState(() => dirty = true),
            decoration:
                const InputDecoration(
              labelText: 'Название',
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
          TextFormField(
            controller: description,
            maxLines: 4,
            validator: (value) =>
                textLength(
              value,
              label: 'Описание',
              min: 10,
              max: 300,
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
                      '/categories',
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
}