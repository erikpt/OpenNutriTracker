import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/features/add_meal/data/repository/products_repository.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/usecase/search_products_usecase.dart';

class MockProductsRepository extends Mock implements ProductsRepository {}

class MockGetIntakeUsecase extends Mock implements GetIntakeUsecase {}

void main() {
  group('SearchProductsUseCase', () {
    late MockProductsRepository productsRepository;
    late MockGetIntakeUsecase getIntakeUsecase;
    late SearchProductsUseCase useCase;

    setUp(() {
      productsRepository = MockProductsRepository();
      getIntakeUsecase = MockGetIntakeUsecase();
      useCase = SearchProductsUseCase(productsRepository, getIntakeUsecase);
    });

    test('prepends matching custom meals for OFF search', () async {
      final customMatch = _meal(
          code: 'custom-1', name: 'Tofu Bowl', source: MealSourceEntity.custom);
      final customNoMatch = _meal(
          code: 'custom-2',
          name: 'Lentil Soup',
          source: MealSourceEntity.custom);
      final offMatchFromHistory = _meal(
          code: 'off-history',
          name: 'Tofu Snack',
          source: MealSourceEntity.off);
      final offApiResult = _meal(
          code: 'off-api', name: 'Tofu Product', source: MealSourceEntity.off);

      when(productsRepository.getOFFProductsByString('tofu'))
          .thenAnswer((_) async => [offApiResult]);
      when(getIntakeUsecase.getRecentIntake()).thenAnswer((_) async => [
            _intake('i1', customNoMatch),
            _intake('i2', offMatchFromHistory),
            _intake('i3', customMatch),
          ]);

      final result = await useCase.searchOFFProductsByString('tofu');

      expect(result, [customMatch, offApiResult]);
    });

    test('deduplicates repeated custom meals for FDC search', () async {
      final customMatch = _meal(
          code: 'custom-apple',
          name: 'Apple Mix',
          source: MealSourceEntity.custom);
      final fdcApiResult = _meal(
          code: 'fdc-api',
          name: 'Apple Nutrition',
          source: MealSourceEntity.fdc);

      when(productsRepository.getSupabaseFDCFoodsByString('apple'))
          .thenAnswer((_) async => [fdcApiResult]);
      when(getIntakeUsecase.getRecentIntake()).thenAnswer((_) async => [
            _intake('i1', customMatch),
            _intake('i2', customMatch),
          ]);

      final result = await useCase.searchFDCFoodByString('apple');

      expect(result, [customMatch, fdcApiResult]);
    });

    test('does not query recent intake for blank search strings', () async {
      final offApiResult = _meal(
          code: 'off-api', name: 'Any Product', source: MealSourceEntity.off);

      when(productsRepository.getOFFProductsByString('   '))
          .thenAnswer((_) async => [offApiResult]);

      final result = await useCase.searchOFFProductsByString('   ');

      expect(result, [offApiResult]);
      verifyNever(getIntakeUsecase.getRecentIntake());
    });

    test('matches custom meals by brand case-insensitively', () async {
      final customBrandMatch = MealEntity(
          code: 'custom-brand',
          name: 'Snack',
          brands: 'Almond Co',
          thumbnailImageUrl: null,
          mainImageUrl: null,
          url: null,
          mealQuantity: null,
          mealUnit: 'g',
          servingQuantity: null,
          servingUnit: 'g',
          servingSize: null,
          nutriments: MealNutrimentsEntity.empty(),
          source: MealSourceEntity.custom);
      final fdcApiResult = _meal(
          code: 'fdc-api',
          name: 'Almond Product',
          source: MealSourceEntity.fdc);

      when(productsRepository.getSupabaseFDCFoodsByString('ALMOND'))
          .thenAnswer((_) async => [fdcApiResult]);
      when(getIntakeUsecase.getRecentIntake())
          .thenAnswer((_) async => [_intake('i1', customBrandMatch)]);

      final result = await useCase.searchFDCFoodByString('ALMOND');

      expect(result, [customBrandMatch, fdcApiResult]);
    });

    test('deduplicates custom meals when code is missing by fallback name key',
        () async {
      final customNoCode = MealEntity(
          code: null,
          name: 'Peanut Butter',
          brands: null,
          thumbnailImageUrl: null,
          mainImageUrl: null,
          url: null,
          mealQuantity: null,
          mealUnit: 'g',
          servingQuantity: null,
          servingUnit: 'g',
          servingSize: null,
          nutriments: MealNutrimentsEntity.empty(),
          source: MealSourceEntity.custom);
      final offApiResult = _meal(
          code: 'off-api',
          name: 'Peanut Product',
          source: MealSourceEntity.off);

      when(productsRepository.getOFFProductsByString('peanut'))
          .thenAnswer((_) async => [offApiResult]);
      when(getIntakeUsecase.getRecentIntake()).thenAnswer((_) async => [
            _intake('i1', customNoCode),
            _intake('i2', customNoCode),
          ]);

      final result = await useCase.searchOFFProductsByString('peanut');

      expect(result, [customNoCode, offApiResult]);
    });
  });
}

MealEntity _meal(
    {required String code,
    required String name,
    required MealSourceEntity source}) {
  return MealEntity(
      code: code,
      name: name,
      brands: null,
      thumbnailImageUrl: null,
      mainImageUrl: null,
      url: null,
      mealQuantity: null,
      mealUnit: 'g',
      servingQuantity: null,
      servingUnit: 'g',
      servingSize: null,
      nutriments: MealNutrimentsEntity.empty(),
      source: source);
}

IntakeEntity _intake(String id, MealEntity meal) {
  return IntakeEntity(
      id: id,
      unit: 'g',
      amount: 100,
      type: IntakeTypeEntity.breakfast,
      meal: meal,
      dateTime: DateTime.utc(2024, 1, 1));
}
