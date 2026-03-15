import 'package:opennutritracker/core/data/repository/water_repository.dart';
import 'package:opennutritracker/core/domain/entity/water_intake_entity.dart';
import 'package:opennutritracker/core/utils/id_generator.dart';

class AddWaterUsecase {
  final WaterRepository _waterRepository;

  AddWaterUsecase(this._waterRepository);

  Future<void> addWaterIntake(double amountMl) async {
    final entity = WaterIntakeEntity(
      id: IdGenerator.getUniqueID(),
      dateTime: DateTime.now(),
      amountMl: amountMl,
    );
    await _waterRepository.addWaterIntake(entity);
  }

  Future<void> deleteWaterIntake(String id) async {
    await _waterRepository.deleteWaterIntake(id);
  }
}
