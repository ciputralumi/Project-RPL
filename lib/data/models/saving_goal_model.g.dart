// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saving_goal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavingGoalModelAdapter extends TypeAdapter<SavingGoalModel> {
  @override
  final int typeId = 40;

  @override
  SavingGoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingGoalModel(
      title: fields[0] as String,
      target: fields[1] as double,
      saved: fields[2] as double,
      deadline: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SavingGoalModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.target)
      ..writeByte(2)
      ..write(obj.saved)
      ..writeByte(3)
      ..write(obj.deadline);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingGoalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
