// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaterialItemAdapter extends TypeAdapter<MaterialItem> {
  @override
  final int typeId = 5;

  @override
  MaterialItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialItem(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as MaterialCategory,
      brand: fields[3] as String,
      color: fields[4] as String,
      stockGrams: fields[5] as double,
      pricePerKg: fields[6] as double,
      createdAt: fields[7] as DateTime,
      notes: fields[8] as String?,
      minStockGrams: fields[9] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.brand)
      ..writeByte(4)
      ..write(obj.color)
      ..writeByte(5)
      ..write(obj.stockGrams)
      ..writeByte(6)
      ..write(obj.pricePerKg)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.minStockGrams);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MaterialCategoryAdapter extends TypeAdapter<MaterialCategory> {
  @override
  final int typeId = 4;

  @override
  MaterialCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MaterialCategory.filament;
      case 1:
        return MaterialCategory.resin;
      case 2:
        return MaterialCategory.support;
      case 3:
        return MaterialCategory.other;
      default:
        return MaterialCategory.filament;
    }
  }

  @override
  void write(BinaryWriter writer, MaterialCategory obj) {
    switch (obj) {
      case MaterialCategory.filament:
        writer.writeByte(0);
        break;
      case MaterialCategory.resin:
        writer.writeByte(1);
        break;
      case MaterialCategory.support:
        writer.writeByte(2);
        break;
      case MaterialCategory.other:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
