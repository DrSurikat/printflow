// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderAdapter extends TypeAdapter<Order> {
  @override
  final int typeId = 0;

  @override
  Order read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Order(
      id: fields[0] as String,
      clientId: fields[1] as String,
      clientName: fields[2] as String,
      createdAt: fields[3] as DateTime,
      deadline: fields[4] as DateTime?,
      status: fields[5] as OrderStatus,
      items: (fields[6] as List).cast<OrderItem>(),
      notes: fields[7] as String?,
      number: fields[8] as String,
      discount: fields[9] as double?,
      paymentMethod: fields[10] as String?,
      isPaid: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Order obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clientId)
      ..writeByte(2)
      ..write(obj.clientName)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.deadline)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.items)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.number)
      ..writeByte(9)
      ..write(obj.discount)
      ..writeByte(10)
      ..write(obj.paymentMethod)
      ..writeByte(11)
      ..write(obj.isPaid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderStatusAdapter extends TypeAdapter<OrderStatus> {
  @override
  final int typeId = 3;

  @override
  OrderStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OrderStatus.new_;
      case 1:
        return OrderStatus.inProgress;
      case 2:
        return OrderStatus.readyForPickup;
      case 3:
        return OrderStatus.completed;
      case 4:
        return OrderStatus.cancelled;
      default:
        return OrderStatus.new_;
    }
  }

  @override
  void write(BinaryWriter writer, OrderStatus obj) {
    switch (obj) {
      case OrderStatus.new_:
        writer.writeByte(0);
        break;
      case OrderStatus.inProgress:
        writer.writeByte(1);
        break;
      case OrderStatus.readyForPickup:
        writer.writeByte(2);
        break;
      case OrderStatus.completed:
        writer.writeByte(3);
        break;
      case OrderStatus.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
