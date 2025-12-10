// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_budget_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonthlyBudgetModelAdapter extends TypeAdapter<MonthlyBudgetModel> {
  @override
  final int typeId = 30;

  @override
  MonthlyBudgetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthlyBudgetModel(
      category: fields[0] as String,
      limit: fields[1] as double,
      month: fields[2] as int,
      year: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MonthlyBudgetModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.limit)
      ..writeByte(2)
      ..write(obj.month)
      ..writeByte(3)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyBudgetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
