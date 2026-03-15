import 'package:opennutritracker/core/data/data_source/water_data_source.dart';
import 'package:opennutritracker/core/data/dbo/water_intake_dbo.dart';
import 'package:opennutritracker/core/domain/entity/water_intake_entity.dart';

class WaterRepository {
  final WaterDataSource _waterDataSource;

  WaterRepository(this._waterDataSource);

  Future<void> addWaterIntake(WaterIntakeEntity entity) async {
    final dbo = WaterIntakeDBO.fromEntity(entity);
    await _waterDataSource.addWaterIntake(dbo);
  }

  Future<List<WaterIntakeEntity>> getTodayWaterIntakes(DateTime date) async {
    final dboList = await _waterDataSource.getTodayWaterIntakes(date);
    return dboList.map((dbo) => WaterIntakeEntity.fromDBO(dbo)).toList();
  }

  Future<void> deleteWaterIntake(String id) async {
    await _waterDataSource.deleteWaterIntake(id);
  }
}
