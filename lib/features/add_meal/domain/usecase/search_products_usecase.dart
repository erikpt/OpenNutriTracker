import 'package:logging/logging.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/features/add_meal/data/repository/products_repository.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';

/// Output of a product/food search. [meals] is the deduplicated list shown
/// to the user (custom-meal matches first, then remote results).
/// [remoteSourceEmpty] is true when the remote source returned zero rows
/// or failed (rate limit, timeout, network error). The UI uses this to
/// decide whether to render a "no remote results" hint below the custom-meal
/// matches.
class SearchProductsResult {
  final List<MealEntity> meals;
  final bool remoteSourceEmpty;

  const SearchProductsResult({
    required this.meals,
    required this.remoteSourceEmpty,
  });
}

class SearchProductsUseCase {
  final _log = Logger('SearchProductsUseCase');

  final ProductsRepository _productsRepository;
  final GetIntakeUsecase _getIntakeUsecase;

  SearchProductsUseCase(this._productsRepository, this._getIntakeUsecase);

  Future<SearchProductsResult> searchOFFProductsByString(
    String searchString,
  ) async {
    final remote = await _safeRemoteCall(
      'OFF',
      () => _productsRepository.getOFFProductsByString(searchString),
    );
    return _buildResult(searchString, remote);
  }

  Future<SearchProductsResult> searchFDCFoodByString(String searchString) async {
    final remote = await _safeRemoteCall(
      'FDC',
      () => _productsRepository.getSupabaseFDCFoodsByString(searchString),
    );
    return _buildResult(searchString, remote);
  }

  /// Run a remote search and fall back to an empty list when the source
  /// throws (rate limit, timeout, network failure, etc). The caller still
  /// receives matching custom meals from local intake history even when the
  /// remote API is unavailable.
  Future<List<MealEntity>> _safeRemoteCall(
    String sourceLabel,
    Future<List<MealEntity>> Function() call,
  ) async {
    try {
      return await call();
    } catch (exception, stack) {
      _log.warning(
        '$sourceLabel search failed; falling back to custom-meal results only',
        exception,
        stack,
      );
      return const [];
    }
  }

  Future<SearchProductsResult> _buildResult(
    String searchString,
    List<MealEntity> remoteResults,
  ) async {
    final remoteSourceEmpty = remoteResults.isEmpty;

    final normalizedSearchString = searchString.trim().toLowerCase();
    if (normalizedSearchString.isEmpty) {
      return SearchProductsResult(
        meals: remoteResults,
        remoteSourceEmpty: remoteSourceEmpty,
      );
    }

    final recentIntake = await _getIntakeUsecase.getRecentIntake();
    final customMeals = recentIntake
        .map((intake) => intake.meal)
        .where((meal) => meal.source == MealSourceEntity.custom)
        .where((meal) => _mealMatchesSearch(meal, normalizedSearchString))
        .toList();

    return SearchProductsResult(
      meals: _deduplicateMeals([...customMeals, ...remoteResults]),
      remoteSourceEmpty: remoteSourceEmpty,
    );
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
