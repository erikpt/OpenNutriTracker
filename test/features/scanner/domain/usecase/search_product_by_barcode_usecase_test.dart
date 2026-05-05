import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/data/data_source/custom_meal_data_source.dart';
import 'package:opennutritracker/core/data/dbo/meal_dbo.dart';
import 'package:opennutritracker/core/data/dbo/meal_nutriments_dbo.dart';
import 'package:opennutritracker/features/add_meal/data/repository/products_repository.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:opennutritracker/features/scanner/domain/usecase/search_product_by_barcode_usecase.dart';

void main() {
  group('SearchProductByBarcodeUseCase', () {
    late _FakeProductsRepository repo;
    late _FakeCustomMealDataSource customMealDataSource;
    late SearchProductByBarcodeUseCase useCase;

    setUp(() {
      repo = _FakeProductsRepository();
      customMealDataSource = _FakeCustomMealDataSource();
      useCase = SearchProductByBarcodeUseCase(repo, customMealDataSource);
    });

    test(
        'returns the local custom meal without hitting OFF when the barcode '
        'matches', () async {
      final localMatch = _customMealDbo(code: '1234567890123', name: 'Local');
      customMealDataSource.meals.add(localMatch);
      repo.barcodeResult = MealEntity(
        code: '1234567890123',
        name: 'OFF Result',
        url: null,
        mealQuantity: '100',
        mealUnit: 'g',
        servingQuantity: null,
        servingUnit: 'g',
        servingSize: null,
        nutriments: _emptyNutriments(),
        source: MealSourceEntity.off,
      );

      final result = await useCase.searchProductByBarcode('1234567890123');

      expect(result.name, 'Local');
      expect(result.source, MealSourceEntity.custom);
      expect(repo.getOFFProductByBarcodeCalls, 0,
          reason: 'OFF should not be queried when a local match exists');
    });

    test('falls back to OFF when no local match exists', () async {
      customMealDataSource.meals
          .add(_customMealDbo(code: 'other', name: 'Other'));
      repo.barcodeResult = MealEntity(
        code: 'unknown-barcode',
        name: 'OFF Result',
        url: null,
        mealQuantity: '100',
        mealUnit: 'g',
        servingQuantity: null,
        servingUnit: 'g',
        servingSize: null,
        nutriments: _emptyNutriments(),
        source: MealSourceEntity.off,
      );

      final result = await useCase.searchProductByBarcode('unknown-barcode');

      expect(result.name, 'OFF Result');
      expect(result.source, MealSourceEntity.off);
      expect(repo.getOFFProductByBarcodeCalls, 1);
    });

    test('ignores custom meals whose code is null', () async {
      customMealDataSource.meals.add(_customMealDbo(code: null, name: 'NoCode'));
      repo.barcodeResult = MealEntity(
        code: '1234',
        name: 'OFF Result',
        url: null,
        mealQuantity: '100',
        mealUnit: 'g',
        servingQuantity: null,
        servingUnit: 'g',
        servingSize: null,
        nutriments: _emptyNutriments(),
        source: MealSourceEntity.off,
      );

      final result = await useCase.searchProductByBarcode('1234');

      expect(result.source, MealSourceEntity.off);
    });
  });
}

class _FakeCustomMealDataSource implements CustomMealDataSource {
  final List<MealDBO> meals = [];

  @override
  List<MealDBO> getAllCustomMeals() => meals;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Unexpected call: ${invocation.memberName}');
}

class _FakeProductsRepository implements ProductsRepository {
  MealEntity? barcodeResult;
  int getOFFProductByBarcodeCalls = 0;

  @override
  Future<MealEntity> getOFFProductByBarcode(String barcode) async {
    getOFFProductByBarcodeCalls++;
    return barcodeResult!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Unexpected call: ${invocation.memberName}');
}

MealDBO _customMealDbo({required String? code, required String name}) {
  return MealDBO(
    code: code,
    name: name,
    brands: null,
    thumbnailImageUrl: null,
    mainImageUrl: null,
    url: null,
    mealQuantity: '100',
    mealUnit: 'g',
    servingQuantity: null,
    servingUnit: 'g',
    servingSize: null,
    source: MealSourceDBO.custom,
    nutriments: MealNutrimentsDBO(
      energyKcal100: 0,
      carbohydrates100: null,
      fat100: null,
      proteins100: null,
      sugars100: null,
      saturatedFat100: null,
      fiber100: null,
    ),
  );
}

MealNutrimentsEntity _emptyNutriments() => const MealNutrimentsEntity(
      energyKcal100: 0,
      carbohydrates100: null,
      fat100: null,
      proteins100: null,
      sugars100: null,
      saturatedFat100: null,
      fiber100: null,
    );
