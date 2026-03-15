import 'package:hive_flutter/hive_flutter.dart';
import 'package:opennutritracker/core/domain/entity/water_intake_entity.dart';

part 'water_intake_dbo.g.dart';

@HiveType(typeId: 16)
class WaterIntakeDBO extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime dateTime;

  @HiveField(2)
  double amountMl;

  WaterIntakeDBO({
    required this.id,
    required this.dateTime,
    required this.amountMl,
  });

  factory WaterIntakeDBO.fromEntity(WaterIntakeEntity entity) {
    return WaterIntakeDBO(
      id: entity.id,
      dateTime: entity.dateTime,
      amountMl: entity.amountMl,
    );
  }
}
