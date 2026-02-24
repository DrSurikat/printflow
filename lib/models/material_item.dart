import 'package:hive/hive.dart';

part 'material_item.g.dart';

@HiveType(typeId: 4)
enum MaterialCategory {
  @HiveField(0)
  filament,

  @HiveField(1)
  resin,

  @HiveField(2)
  support,

  @HiveField(3)
  other,
}

extension MaterialCategoryExtension on MaterialCategory {
  String get label {
    switch (this) {
      case MaterialCategory.filament:
        return 'Філамент';
      case MaterialCategory.resin:
        return 'Смола';
      case MaterialCategory.support:
        return 'Підтримки';
      case MaterialCategory.other:
        return 'Інше';
    }
  }

  int get colorValue {
    switch (this) {
      case MaterialCategory.filament:
        return 0xFF6C63FF;
      case MaterialCategory.resin:
        return 0xFF03DAC6;
      case MaterialCategory.support:
        return 0xFFFFB347;
      case MaterialCategory.other:
        return 0xFF7878A0;
    }
  }
}

@HiveType(typeId: 5)
class MaterialItem extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late MaterialCategory category;

  @HiveField(3)
  late String brand;

  @HiveField(4)
  late String color;

  @HiveField(5)
  late double stockGrams; // quantity in grams

  @HiveField(6)
  late double pricePerKg; // price per kilogram in UAH

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  String? notes;

  @HiveField(9)
  double? minStockGrams; // low stock alert threshold

  MaterialItem({
    required this.id,
    required this.name,
    required this.category,
    this.brand = '',
    this.color = '',
    this.stockGrams = 0,
    this.pricePerKg = 0,
    required this.createdAt,
    this.notes,
    this.minStockGrams,
  });

  bool get isLowStock => minStockGrams != null && stockGrams <= minStockGrams!;

  double get stockKg => stockGrams / 1000;

  double get totalValue => stockKg * pricePerKg;

  MaterialItem copyWith({
    String? id,
    String? name,
    MaterialCategory? category,
    String? brand,
    String? color,
    double? stockGrams,
    double? pricePerKg,
    DateTime? createdAt,
    String? notes,
    double? minStockGrams,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      stockGrams: stockGrams ?? this.stockGrams,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      minStockGrams: minStockGrams ?? this.minStockGrams,
    );
  }
}
