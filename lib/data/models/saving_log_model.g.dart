// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saving_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavingLogModelAdapter extends TypeAdapter<SavingLogModel> {
  @override
  final int typeId = 90;

  @override
  SavingLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingLogModel(
      goalKey: fields[0] as int,
      amount: fields[1] as double,
      date: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavingLogModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.goalKey)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
