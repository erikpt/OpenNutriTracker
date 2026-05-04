import 'package:opennutritracker/core/data/data_source/custom_meal_data_source.dart';
import 'package:opennutritracker/features/add_meal/data/repository/products_repository.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';

class SearchProductByBarcodeUseCase {
  final ProductsRepository _productsRepository;
  final CustomMealDataSource _customMealDataSource;

  SearchProductByBarcodeUseCase(
    this._productsRepository,
    this._customMealDataSource,
  );

  /// Look up a barcode locally first (in the user's custom-meal store) so
  /// scanning a previously-imported product is instant and works offline.
  /// Falls back to the Open Food Facts API only when no local match exists.
  Future<MealEntity> searchProductByBarcode(String barcode) async {
    final localMatch = _customMealDataSource
        .getAllCustomMeals()
        .where((dbo) => dbo.code != null && dbo.code == barcode)
        .firstOrNull;
    if (localMatch != null) {
      return MealEntity.fromMealDBO(localMatch);
    }
    return _productsRepository.getOFFProductByBarcode(barcode);
  }
}
