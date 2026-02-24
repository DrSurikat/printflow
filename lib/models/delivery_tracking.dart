import 'package:hive/hive.dart';

part 'delivery_tracking.g.dart';

@HiveType(typeId: 9)
enum DeliveryCarrier {
  @HiveField(0)
  novaPoshta,

  @HiveField(1)
  ukrposhta,
}

extension DeliveryCarrierExtension on DeliveryCarrier {
  String get label {
    switch (this) {
      case DeliveryCarrier.novaPoshta:
        return 'Нова Пошта';
      case DeliveryCarrier.ukrposhta:
        return 'Укрпошта';
    }
  }
}

@HiveType(typeId: 10)
class DeliveryTracking extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String orderId;

  @HiveField(2)
  late String orderNumber;

  @HiveField(3)
  late DeliveryCarrier carrier;

  @HiveField(4)
  late String trackingNumber;

  @HiveField(5)
  String lastStatus;

  @HiveField(6)
  late DateTime lastUpdated;

  @HiveField(7)
  List<String> history;

  DeliveryTracking({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.carrier,
    required this.trackingNumber,
    this.lastStatus = 'Очікування даних...',
    required this.lastUpdated,
    List<String>? history,
  }) : history = history ?? [];
}
