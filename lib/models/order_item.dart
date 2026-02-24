import 'package:hive/hive.dart';

part 'order_item.g.dart';

@HiveType(typeId: 2)
class OrderItem extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late int quantity;

  @HiveField(4)
  late double unitPrice;

  @HiveField(5)
  String? unit; // e.g., 'шт', 'кг', 'м²'

  OrderItem({
    required this.id,
    required this.name,
    this.description = '',
    required this.quantity,
    required this.unitPrice,
    this.unit = 'шт',
  });

  double get totalPrice => quantity * unitPrice;

  OrderItem copyWith({
    String? id,
    String? name,
    String? description,
    int? quantity,
    double? unitPrice,
    String? unit,
  }) {
    return OrderItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'unit': unit,
      };
}
