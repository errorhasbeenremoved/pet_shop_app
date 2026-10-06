import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class PersistentDataStore {
  static const _key = 'pet_shop_data_v2';
  static const _legacyKey = 'pet_shop_data_v1';
  final SharedPreferences prefs;
  final Map<String, List<Map<String, dynamic>>> _data = {};
  bool migratedFromLegacy = false;

  PersistentDataStore(this.prefs);

  Future<void> initialize() async {
    final raw = prefs.getString(_key);
    if (raw == null) {
      final legacy = prefs.getString(_legacyKey);
      if (legacy != null) {
        migratedFromLegacy = true;
      }
      _seed();
      await persist();
      return;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) throw const FormatException();
      final version = decoded['version'];
      if (version != 2) throw const FormatException();
      final entities = decoded['entities'];
      if (entities is! Map) throw const FormatException();
      for (final entry in entities.entries) {
        final value = entry.value;
        if (value is List) {
          _data[entry.key.toString()] = value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
      _ensureSeedsForMissingEntities();
    } catch (_) {
      _data.clear();
      _seed();
      await persist();
    }
  }

  List<Map<String, dynamic>> read(String entity) => List.unmodifiable(_data[entity] ?? const []);

  Future<void> write(String entity, List<Map<String, dynamic>> rows) async {
    _data[entity] = rows.map(Map<String, dynamic>.from).toList();
    await persist();
  }

  Future<void> persist() async {
    await prefs.setString(_key, jsonEncode({'version': 2, 'entities': _data}));
  }

  void _seed() {
    _data['brands'] = seedBrands.map((e) => e.toJson()).toList();
    _data['categories'] = seedCategories.map((e) => e.toJson()).toList();
    _data['suppliers'] = seedSuppliers.map((e) => e.toJson()).toList();
    _data['products'] = seedProducts.map((e) => e.toJson()).toList();
    _data['customers'] = seedCustomers.map((e) => e.toJson()).toList();
  }

  void _ensureSeedsForMissingEntities() {
    final seeds = {
      'brands': seedBrands.map((e) => e.toJson()).toList(),
      'categories': seedCategories.map((e) => e.toJson()).toList(),
      'suppliers': seedSuppliers.map((e) => e.toJson()).toList(),
      'products': seedProducts.map((e) => e.toJson()).toList(),
      'customers': seedCustomers.map((e) => e.toJson()).toList(),
    };
    for (final entry in seeds.entries) {
      _data.putIfAbsent(entry.key, () => entry.value);
    }
  }
}
