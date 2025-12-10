// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saving_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavingLogModelAdapter extends TypeAdapter<SavingLogModel> {
  @override
  final int typeId = 41;

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
      note: fields[3] as String,
      transactionKey: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SavingLogModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.goalKey)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.transactionKey);
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
