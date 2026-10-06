import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/data_store.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.read<PersistentDataStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('Зоомаркет')),
      body: Column(
        children: [
          if (store.migratedFromLegacy)
            MaterialBanner(
              content: const Text('Обнаружена старая версия формата данных. Используется новый ключ хранилища v2, приложение продолжило работу без падения.'),
              actions: [TextButton(onPressed: () {}, child: const Text('Понятно'))],
            ),
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _tile(context, 'Товары', '/products', Icons.pets),
                  _tile(context, 'Бренды', '/brands', Icons.sell),
                  _tile(context, 'Категории', '/categories', Icons.category),
                  _tile(context, 'Поставщики', '/suppliers', Icons.local_shipping),
                  _tile(context, 'Клиенты', '/customers', Icons.people),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _tile(BuildContext context, String title, String path, IconData icon) => SizedBox(
        width: 220,
        height: 100,
        child: Card(
          child: InkWell(
            onTap: () => context.go(path),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))]),
          ),
        ),
      );
}
