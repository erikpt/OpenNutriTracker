import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/features/add_meal/data/repository/products_repository.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';

class SearchProductsUseCase {
  final ProductsRepository _productsRepository;
  final GetIntakeUsecase _getIntakeUsecase;

  SearchProductsUseCase(this._productsRepository, this._getIntakeUsecase);

  Future<List<MealEntity>> searchOFFProductsByString(
    String searchString,
  ) async {
    final products = await _productsRepository.getOFFProductsByString(
      searchString,
    );
    return _prependMatchingCustomMeals(searchString, products);
  }

  Future<List<MealEntity>> searchFDCFoodByString(String searchString) async {
    final foods = await _productsRepository.getSupabaseFDCFoodsByString(
      searchString,
    );
    return _prependMatchingCustomMeals(searchString, foods);
  }

  Future<List<MealEntity>> _prependMatchingCustomMeals(
    String searchString,
    List<MealEntity> remoteResults,
  ) async {
    final normalizedSearchString = searchString.trim().toLowerCase();
    if (normalizedSearchString.isEmpty) {
      return remoteResults;
    }

    final recentIntake = await _getIntakeUsecase.getRecentIntake();
    final customMeals = recentIntake
        .map((intake) => intake.meal)
        .where((meal) => meal.source == MealSourceEntity.custom)
        .where((meal) => _mealMatchesSearch(meal, normalizedSearchString))
        .toList();

    return _deduplicateMeals([...customMeals, ...remoteResults]);
  }

  bool _mealMatchesSearch(MealEntity meal, String normalizedSearchString) {
    return (meal.name?.toLowerCase().contains(normalizedSearchString) ??
            false) ||
        (meal.brands?.toLowerCase().contains(normalizedSearchString) ?? false);
  }

  List<MealEntity> _deduplicateMeals(List<MealEntity> meals) {
    final seenKeys = <String>{};
    final uniqueMeals = <MealEntity>[];

    for (final meal in meals) {
      final key = '${meal.source.name}:${meal.code ?? meal.name ?? ''}';
      if (seenKeys.add(key)) {
        uniqueMeals.add(meal);
      }
    }

    return uniqueMeals;
  }
}
