import 'package:opennutritracker/core/data/dbo/water_intake_dbo.dart';

class WaterIntakeEntity {
  final String id;
  final DateTime dateTime;
  final double amountMl;

  const WaterIntakeEntity({
    required this.id,
    required this.dateTime,
    required this.amountMl,
  });

  factory WaterIntakeEntity.fromDBO(WaterIntakeDBO dbo) {
    return WaterIntakeEntity(
      id: dbo.id,
      dateTime: dbo.dateTime,
      amountMl: dbo.amountMl,
    );
  }
}
