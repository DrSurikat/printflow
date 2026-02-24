import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/material_item.dart';

class MaterialProvider extends ChangeNotifier {
  final Box<MaterialItem> _box = Hive.box<MaterialItem>('materials');
  final _uuid = const Uuid();

  String _searchQuery = '';
  MaterialCategory? _filterCategory;

  List<MaterialItem> get all =>
      _box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<MaterialItem> get filtered {
    var list = all;
    if (_filterCategory != null) {
      list = list.where((m) => m.category == _filterCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((m) {
        return m.name.toLowerCase().contains(q) ||
            m.brand.toLowerCase().contains(q) ||
            m.color.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  List<MaterialItem> get lowStock => all.where((m) => m.isLowStock).toList();

  String get searchQuery => _searchQuery;
  MaterialCategory? get filterCategory => _filterCategory;

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setFilterCategory(MaterialCategory? c) {
    _filterCategory = c;
    notifyListeners();
  }

  int get totalCount => _box.length;
  int get lowStockCount => lowStock.length;

  double get totalInventoryValue => all.fold(0, (sum, m) => sum + m.totalValue);

  Future<MaterialItem> addMaterial({
    required String name,
    required MaterialCategory category,
    String brand = '',
    String color = '',
    double stockGrams = 0,
    double pricePerKg = 0,
    String? notes,
    double? minStockGrams,
  }) async {
    final item = MaterialItem(
      id: _uuid.v4(),
      name: name,
      category: category,
      brand: brand,
      color: color,
      stockGrams: stockGrams,
      pricePerKg: pricePerKg,
      createdAt: DateTime.now(),
      notes: notes,
      minStockGrams: minStockGrams,
    );
    await _box.put(item.id, item);
    notifyListeners();
    return item;
  }

  Future<void> updateMaterial(MaterialItem item) async {
    await _box.put(item.id, item);
    notifyListeners();
  }

  Future<void> adjustStock(String id, double deltaGrams) async {
    final item = _box.get(id);
    if (item == null) return;
    final updated = item.copyWith(
      stockGrams: (item.stockGrams + deltaGrams).clamp(0, double.infinity),
    );
    await _box.put(id, updated);
    notifyListeners();
  }

  Future<void> deleteMaterial(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  MaterialItem? getById(String id) => _box.get(id);
}
