import 'package:go_router/go_router.dart';
import '../models/list_query.dart';
import '../screens/brand_form_screen.dart';
import '../screens/category_form_screen.dart';
import '../screens/customer_form_screen.dart';
import '../screens/entity_list_screen.dart';
import '../screens/home_screen.dart';
import '../screens/product_form_screen.dart';
import '../screens/supplier_form_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/products',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/products',
        builder: (_, state) => EntityListScreen.product(
          initialQuery: ListQuery.fromUri(state.uri),
        ),
      ),
      GoRoute(
        path: '/products/new',
        builder: (_, __) => const ProductFormScreen(),
      ),
      GoRoute(
        path: '/products/:id/edit',
        builder: (_, state) => ProductFormScreen(
          id: int.tryParse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/brands',
        builder: (_, state) => EntityListScreen.brand(
          initialQuery: ListQuery.fromUri(state.uri),
        ),
      ),
      GoRoute(
        path: '/brands/new',
        builder: (_, __) => const BrandFormScreen(),
      ),
      GoRoute(
        path: '/brands/:id/edit',
        builder: (_, state) => BrandFormScreen(
          id: int.tryParse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/categories',
        builder: (_, state) => EntityListScreen.category(
          initialQuery: ListQuery.fromUri(state.uri),
        ),
      ),
      GoRoute(
        path: '/categories/new',
        builder: (_, __) => const CategoryFormScreen(),
      ),
      GoRoute(
        path: '/categories/:id/edit',
        builder: (_, state) => CategoryFormScreen(
          id: int.tryParse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/suppliers',
        builder: (_, state) => EntityListScreen.supplier(
          initialQuery: ListQuery.fromUri(state.uri),
        ),
      ),
      GoRoute(
        path: '/suppliers/new',
        builder: (_, __) => const SupplierFormScreen(),
      ),
      GoRoute(
        path: '/suppliers/:id/edit',
        builder: (_, state) => SupplierFormScreen(
          id: int.tryParse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/customers',
        builder: (_, state) => EntityListScreen.customer(
          initialQuery: ListQuery.fromUri(state.uri),
        ),
      ),
      GoRoute(
        path: '/customers/new',
        builder: (_, __) => const CustomerFormScreen(),
      ),
      GoRoute(
        path: '/customers/:id/edit',
        builder: (_, state) => CustomerFormScreen(
          id: int.tryParse(state.pathParameters['id']!),
        ),
      ),
    ],
  );
}