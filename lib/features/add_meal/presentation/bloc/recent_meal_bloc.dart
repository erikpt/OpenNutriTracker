import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/data_source/custom_meal_data_source.dart';
import 'package:opennutritracker/core/domain/usecase/get_config_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';

part 'recent_meal_event.dart';

part 'recent_meal_state.dart';

class RecentMealBloc extends Bloc<RecentMealEvent, RecentMealState> {
  final log = Logger('RecentMealBloc');

  final GetIntakeUsecase _getIntakeUsecase;
  final GetConfigUsecase _getConfigUsecase;
  final CustomMealDataSource _customMealDataSource; // #267

  RecentMealBloc(this._getIntakeUsecase, this._getConfigUsecase,
      this._customMealDataSource)
      : super(RecentMealInitial()) {
    on<LoadRecentMealEvent>((event, emit) async {
      emit(RecentMealLoadingState());
      try {
        final config = await _getConfigUsecase.getConfig();
        final recentIntake = await _getIntakeUsecase.getRecentIntake();
        final searchString = event.searchString.toLowerCase();

        // Merge logged intakes + custom templates not yet logged (#267)
        final recentMeals = recentIntake.map((intake) => intake.meal).toList();
        final recentKeys =
            recentMeals.map((m) => m.code ?? m.name ?? '').toSet();
        final customMeals = _customMealDataSource
            .getAllCustomMeals()
            .map((dbo) => MealEntity.fromMealDBO(dbo))
            .where((m) => !recentKeys.contains(m.code ?? m.name ?? ''))
            .toList();
        final allMeals = [...recentMeals, ...customMeals];

        final filtered = searchString.isEmpty
            ? allMeals
            : allMeals
                .where((m) => _mealMatchesSearch(m, searchString))
                .toList();

        emit(RecentMealLoadedState(
            recentMeals: filtered,
            usesImperialUnits: config.usesImperialUnits));
      } catch (error) {
        log.severe(error);
        emit(RecentMealFailedState());
      }
    });
  }

  bool _mealMatchesSearch(MealEntity meal, String searchString) =>
      (meal.name?.toLowerCase().contains(searchString) ?? false) ||
      (meal.brands?.toLowerCase().contains(searchString) ?? false) ||
      (meal.code?.toLowerCase().contains(searchString) ?? false);
}
