import 'package:opennutritracker/core/data/repository/water_repository.dart';
import 'package:opennutritracker/core/domain/entity/water_intake_entity.dart';

class GetWaterUsecase {
  final WaterRepository _waterRepository;

  GetWaterUsecase(this._waterRepository);

  Future<List<WaterIntakeEntity>> getTodayWaterIntakes() async {
    return _waterRepository.getTodayWaterIntakes(DateTime.now());
  }
}
