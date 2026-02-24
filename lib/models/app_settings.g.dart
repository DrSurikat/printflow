// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 8;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      novaPoshtaApiKey: fields[0] as String,
      ukrposhtaToken: fields[1] as String,
      senderName: fields[2] as String,
      senderAddress: fields[3] as String,
      senderPhone: fields[4] as String,
      senderIpn: fields[5] as String,
      invoiceFooterText: fields[6] as String,
      invoicePrefix: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.novaPoshtaApiKey)
      ..writeByte(1)
      ..write(obj.ukrposhtaToken)
      ..writeByte(2)
      ..write(obj.senderName)
      ..writeByte(3)
      ..write(obj.senderAddress)
      ..writeByte(4)
      ..write(obj.senderPhone)
      ..writeByte(5)
      ..write(obj.senderIpn)
      ..writeByte(6)
      ..write(obj.invoiceFooterText)
      ..writeByte(7)
      ..write(obj.invoicePrefix);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
