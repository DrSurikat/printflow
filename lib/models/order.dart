import 'package:hive/hive.dart';
import 'order_item.dart';

part 'order.g.dart';

@HiveType(typeId: 0)
class Order extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String clientId;

  @HiveField(2)
  late String clientName;

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  DateTime? deadline;

  @HiveField(5)
  late OrderStatus status;

  @HiveField(6)
  late List<OrderItem> items;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  late String number; // e.g., "ORD-2024-001"

  @HiveField(9)
  double? discount; // percentage 0-100

  @HiveField(10)
  String? paymentMethod;

  @HiveField(11)
  bool isPaid;

  Order({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.createdAt,
    this.deadline,
    this.status = OrderStatus.new_,
    required this.items,
    this.notes,
    required this.number,
    this.discount,
    this.paymentMethod,
    this.isPaid = false,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);

  double get discountAmount =>
      discount != null ? subtotal * (discount! / 100) : 0;

  double get total => subtotal - discountAmount;

  bool get isOverdue =>
      deadline != null &&
      deadline!.isBefore(DateTime.now()) &&
      status != OrderStatus.completed &&
      status != OrderStatus.cancelled;

  Order copyWith({
    String? id,
    String? clientId,
    String? clientName,
    DateTime? createdAt,
    DateTime? deadline,
    OrderStatus? status,
    List<OrderItem>? items,
    String? notes,
    String? number,
    double? discount,
    String? paymentMethod,
    bool? isPaid,
  }) {
    return Order(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      number: number ?? this.number,
      discount: discount ?? this.discount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}

@HiveType(typeId: 3)
enum OrderStatus {
  @HiveField(0)
  new_,

  @HiveField(1)
  inProgress,

  @HiveField(2)
  readyForPickup,

  @HiveField(3)
  completed,

  @HiveField(4)
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.new_:
        return 'Новий';
      case OrderStatus.inProgress:
        return 'В роботі';
      case OrderStatus.readyForPickup:
        return 'Готовий';
      case OrderStatus.completed:
        return 'Виконано';
      case OrderStatus.cancelled:
        return 'Скасовано';
    }
  }

  int get colorValue {
    switch (this) {
      case OrderStatus.new_:
        return 0xFF5B8AF5;
      case OrderStatus.inProgress:
        return 0xFFFFB347;
      case OrderStatus.readyForPickup:
        return 0xFF9B59B6;
      case OrderStatus.completed:
        return 0xFF2ECC71;
      case OrderStatus.cancelled:
        return 0xFFE74C3C;
    }
  }
}
