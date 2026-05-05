import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/data_source/remote_search_cache_data_source.dart';
import 'package:opennutritracker/core/data/data_source/custom_meal_data_source.dart';
import 'package:opennutritracker/core/data/dbo/meal_dbo.dart';
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
  final CustomMealDataSource _customMealDataSource;
  final RemoteSearchCacheDataSource _cachedOffMealDataSource;

  SearchProductsUseCase(
    this._productsRepository,
    this._getIntakeUsecase,
    this._customMealDataSource,
    this._cachedOffMealDataSource,
  );

  Future<SearchProductsResult> searchOFFProductsByString(
    String searchString,
  ) async {
    final remote = await _safeRemoteCall(
      'OFF',
      () => _productsRepository.getOFFProductsByString(searchString),
    );
    // Cache successful remote hits so the same query (and any future
    // barcode scan of these items) resolves locally next time — even
    // offline. Skip when remote came back empty, nothing to cache.
    await _cacheRemoteResults(remote);
    return _buildResult(searchString, remote);
  }

  Future<SearchProductsResult> searchFDCFoodByString(String searchString) async {
    final remote = await _safeRemoteCall(
      'FDC',
      () => _productsRepository.getSupabaseFDCFoodsByString(searchString),
    );
    await _cacheRemoteResults(remote);
    return _buildResult(searchString, remote);
  }

  Future<void> _cacheRemoteResults(List<MealEntity> remote) async {
    if (remote.isEmpty) return;
    await _cachedOffMealDataSource
        .cacheAll(remote.map(MealDBO.fromMealEntity));
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

    // Local sources of matches, in priority order:
    //  1. Custom-meal box: the user's own templates (created or CSV-
    //     imported). Covers entries that haven't been logged as intake.
    //  2. Recent intake history: custom-meal copies the user has logged
    //     even after the original template was deleted.
    //  3. Cached OFF/FDC results: products we previously fetched from the
    //     network. Lets repeat searches and offline use work without a
    //     round-trip — and means freshly-imported users will hit increasing
    //     local hit-rates as they use the app over weeks.
    // All three are passed through the same dedup helper alongside fresh
    // remote results.
    final fromCustomMealBox = _customMealDataSource
        .getAllCustomMeals()
        .map(MealEntity.fromMealDBO)
        .where((meal) => _mealMatchesSearch(meal, normalizedSearchString))
        .toList();

    final recentIntake = await _getIntakeUsecase.getRecentIntake();
    final fromIntakeHistory = recentIntake
        .map((intake) => intake.meal)
        .where((meal) => meal.source == MealSourceEntity.custom)
        .where((meal) => _mealMatchesSearch(meal, normalizedSearchString))
        .toList();

    final fromOffCache = _cachedOffMealDataSource
        .getAll()
        .map(MealEntity.fromMealDBO)
        .where((meal) => _mealMatchesSearch(meal, normalizedSearchString))
        .toList();

    return SearchProductsResult(
      meals: _deduplicateMeals([
        ...fromCustomMealBox,
        ...fromIntakeHistory,
        ...remoteResults,
        ...fromOffCache,
      ]),
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
