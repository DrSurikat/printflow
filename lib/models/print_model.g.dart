// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrintModelAdapter extends TypeAdapter<PrintModel> {
  @override
  final int typeId = 7;

  @override
  PrintModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrintModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      fileType: fields[3] as ModelFileType,
      createdAt: fields[4] as DateTime,
      clientId: fields[5] as String?,
      clientName: fields[6] as String?,
      printTimeHours: fields[7] as double?,
      weightGrams: fields[8] as double?,
      filePath: fields[9] as String?,
      tags: fields[10] as String?,
      printCount: fields[11] as int,
      notes: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PrintModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.fileType)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.clientId)
      ..writeByte(6)
      ..write(obj.clientName)
      ..writeByte(7)
      ..write(obj.printTimeHours)
      ..writeByte(8)
      ..write(obj.weightGrams)
      ..writeByte(9)
      ..write(obj.filePath)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.printCount)
      ..writeByte(12)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ModelFileTypeAdapter extends TypeAdapter<ModelFileType> {
  @override
  final int typeId = 6;

  @override
  ModelFileType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ModelFileType.stl;
      case 1:
        return ModelFileType.obj;
      case 2:
        return ModelFileType.step;
      case 3:
        return ModelFileType.other;
      default:
        return ModelFileType.stl;
    }
  }

  @override
  void write(BinaryWriter writer, ModelFileType obj) {
    switch (obj) {
      case ModelFileType.stl:
        writer.writeByte(0);
        break;
      case ModelFileType.obj:
        writer.writeByte(1);
        break;
      case ModelFileType.step:
        writer.writeByte(2);
        break;
      case ModelFileType.other:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelFileTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
