import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../repositories/repositories.dart';
import '../widgets/form_scaffold.dart';
import '../widgets/reusable_form.dart';
import '../widgets/validators.dart';

class CustomerFormScreen
    extends StatefulWidget {
  final int? id;

  const CustomerFormScreen({
    super.key,
    this.id,
  });

  @override
  State<CustomerFormScreen> createState() =>
      _CustomerFormScreenState();
}

class _CustomerFormScreenState
    extends State<CustomerFormScreen> {
  final form =
      GlobalKey<FormState>();

  late final CustomerRepository repo;

  final name =
      TextEditingController();
  final email =
      TextEditingController();
  final phone =
      TextEditingController();
  final cardNumber =
      TextEditingController();
  final points =
      TextEditingController();

  String level = 'Bronze';

  bool dirty = false;
  bool saving = false;

  String? duplicate;

  @override
  void initState() {
    super.initState();

    repo =
        context.read<CustomerRepository>();

    _load();
  }

  Future<void> _load() async {
    if (widget.id != null) {
      final entity =
          await repo.findById(widget.id!);

      if (entity != null) {
        name.text = entity.name;
        email.text = entity.email;
        phone.text = entity.phone;
        cardNumber.text =
            entity.card.number;
        points.text =
            '${entity.card.bonusPoints}';
        level = entity.card.level;
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
        'email',
        email.text.trim(),
        exceptId: widget.id,
      )) {
        setState(() {
          duplicate =
              'Клиент с таким email уже существует';
        });

        return;
      }

      final entity = Customer(
        id: widget.id ?? 0,
        name: name.text.trim(),
        email: email.text.trim(),
        phone: phone.text.trim(),
        card: LoyaltyCard(
          number: cardNumber.text.trim(),
          level: level,
          bonusPoints:
              int.parse(points.text.trim()),
        ),
      );

      if (widget.id == null) {
        await repo.create(entity);
      } else {
        await repo.update(entity);
      }

      if (mounted) {
        dirty = false;
        context.go('/customers');
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
    email.dispose();
    phone.dispose();
    cardNumber.dispose();
    points.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DirtyFormScaffold(
      title: widget.id == null
          ? 'Новый клиент'
          : 'Редактирование клиента',
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
              label: 'Имя',
              min: 2,
              max: 100,
            ),
            onChanged: (_) =>
                setState(() => dirty = true),
            decoration:
                const InputDecoration(
              labelText: 'Имя',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: email,
            validator: (value) =>
                duplicate ??
                emailValidator(value),
            onChanged: (_) =>
                setState(() => dirty = true),
            decoration:
                const InputDecoration(
              labelText: 'Email',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: phone,
            validator: phoneValidator,
            onChanged: (_) =>
                setState(() => dirty = true),
            decoration:
                const InputDecoration(
              labelText: 'Телефон',
            ),
          ),
          const Divider(height: 32),
          const Text(
            'Карта лояльности',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: cardNumber,
            validator: (value) =>
                textLength(
              value,
              label: 'Номер карты',
              min: 4,
              max: 30,
            ),
            onChanged: (_) =>
                setState(() => dirty = true),
            decoration:
                const InputDecoration(
              labelText: 'Номер карты',
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: level,
            decoration:
                const InputDecoration(
              labelText: 'Уровень',
            ),
            items: const [
              DropdownMenuItem(
                value: 'Bronze',
                child: Text('Bronze'),
              ),
              DropdownMenuItem(
                value: 'Silver',
                child: Text('Silver'),
              ),
              DropdownMenuItem(
                value: 'Gold',
                child: Text('Gold'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                level = value ?? 'Bronze';
                dirty = true;
              });
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: points,
            keyboardType:
                TextInputType.number,
            validator: (value) =>
                nonNegativeInt(
              value,
              label: 'Бонусные баллы',
            ),
            onChanged: (_) =>
                setState(() => dirty = true),
            decoration:
                const InputDecoration(
              labelText: 'Бонусные баллы',
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
                      '/customers',
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