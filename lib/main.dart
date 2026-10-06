import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router.dart';
import 'repositories/repositories.dart';
import 'services/data_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final prefs = await SharedPreferences.getInstance();
  final store = PersistentDataStore(prefs);
  await store.initialize();
  runApp(
    MultiProvider(
      providers: [
        Provider<PersistentDataStore>.value(value: store),
        Provider<ProductRepository>(create: (_) => ProductRepository(store)),
        Provider<BrandRepository>(create: (_) => BrandRepository(store)),
        Provider<CategoryRepository>(create: (_) => CategoryRepository(store)),
        Provider<SupplierRepository>(create: (_) => SupplierRepository(store)),
        Provider<CustomerRepository>(create: (_) => CustomerRepository(store)),
      ],
      child: const PetShopApp(),
    ),
  );
}

class PetShopApp extends StatelessWidget {
  const PetShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Зоомаркет',
      debugShowCheckedModeBanner: false,
      routerConfig: createRouter(),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
        cardTheme: const CardThemeData(margin: EdgeInsets.zero),
      ),
    );
  }
}
