import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/features/add_meal/data/repository/products_repository.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/usecase/search_products_usecase.dart';

class _FakeProductsRepository implements ProductsRepository {
  final Map<String, List<MealEntity>> offResults = {};
  final Map<String, List<MealEntity>> fdcResults = {};

  /// Search strings whose remote call should throw (simulates rate-limit /
  /// network failure / 5xx).
  final Set<String> offThrowOn = {};
  final Set<String> fdcThrowOn = {};

  @override
  Future<List<MealEntity>> getOFFProductsByString(String searchString) async {
    if (offThrowOn.contains(searchString)) {
      throw Exception('OFF HTTP 429');
    }
    return offResults[searchString] ?? const [];
  }

  @override
  Future<List<MealEntity>> getSupabaseFDCFoodsByString(
    String searchString,
  ) async {
    if (fdcThrowOn.contains(searchString)) {
      throw Exception('FDC HTTP 429');
    }
    return fdcResults[searchString] ?? const [];
  }

  // Other ProductsRepository methods aren't exercised here — throw via
  // noSuchMethod if anything unexpectedly hits them.
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Unexpected call: ${invocation.memberName}',
    );
  }
}

class _FakeGetIntakeUsecase implements GetIntakeUsecase {
  List<IntakeEntity> recentIntake = const [];
  int recentIntakeCallCount = 0;

  @override
  Future<List<IntakeEntity>> getRecentIntake() async {
    recentIntakeCallCount++;
    return recentIntake;
  }

  // Stub everything else — only getRecentIntake is exercised here.
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Unexpected call: ${invocation.memberName}',
    );
  }
}

void main() {
  group('SearchProductsUseCase', () {
    late _FakeProductsRepository productsRepository;
    late _FakeGetIntakeUsecase getIntakeUsecase;
    late SearchProductsUseCase useCase;

    setUp(() {
      productsRepository = _FakeProductsRepository();
      getIntakeUsecase = _FakeGetIntakeUsecase();
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

      productsRepository.offResults['tofu'] = [offApiResult];
      getIntakeUsecase.recentIntake = [
        _intake('i1', customNoMatch),
        _intake('i2', offMatchFromHistory),
        _intake('i3', customMatch),
      ];

      final result = await useCase.searchOFFProductsByString('tofu');

      expect(result.meals, [customMatch, offApiResult]);
      expect(result.remoteSourceEmpty, isFalse);
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

      productsRepository.fdcResults['apple'] = [fdcApiResult];
      getIntakeUsecase.recentIntake = [
        _intake('i1', customMatch),
        _intake('i2', customMatch),
      ];

      final result = await useCase.searchFDCFoodByString('apple');

      expect(result.meals, [customMatch, fdcApiResult]);
      expect(result.remoteSourceEmpty, isFalse);
    });

    test('does not query recent intake for blank search strings', () async {
      final offApiResult = _meal(
          code: 'off-api', name: 'Any Product', source: MealSourceEntity.off);

      productsRepository.offResults['   '] = [offApiResult];

      final result = await useCase.searchOFFProductsByString('   ');

      expect(result.meals, [offApiResult]);
      expect(getIntakeUsecase.recentIntakeCallCount, 0);
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

      productsRepository.fdcResults['ALMOND'] = [fdcApiResult];
      getIntakeUsecase.recentIntake = [_intake('i1', customBrandMatch)];

      final result = await useCase.searchFDCFoodByString('ALMOND');

      expect(result.meals, [customBrandMatch, fdcApiResult]);
      expect(result.remoteSourceEmpty, isFalse);
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

      productsRepository.offResults['peanut'] = [offApiResult];
      getIntakeUsecase.recentIntake = [
        _intake('i1', customNoCode),
        _intake('i2', customNoCode),
      ];

      final result = await useCase.searchOFFProductsByString('peanut');

      expect(result.meals, [customNoCode, offApiResult]);
      expect(result.remoteSourceEmpty, isFalse);
    });

    test(
      'returns custom meals + remoteSourceEmpty=true when OFF rate-limits',
      () async {
        final customMatch = _meal(
            code: 'custom-tofu',
            name: 'Tofu Bowl',
            source: MealSourceEntity.custom);

        productsRepository.offThrowOn.add('tofu');
        getIntakeUsecase.recentIntake = [_intake('i1', customMatch)];

        final result = await useCase.searchOFFProductsByString('tofu');

        expect(result.meals, [customMatch]);
        expect(result.remoteSourceEmpty, isTrue);
      },
    );

    test(
      'returns custom meals + remoteSourceEmpty=true when FDC rate-limits',
      () async {
        final customMatch = _meal(
            code: 'custom-apple',
            name: 'Apple Mix',
            source: MealSourceEntity.custom);

        productsRepository.fdcThrowOn.add('apple');
        getIntakeUsecase.recentIntake = [_intake('i1', customMatch)];

        final result = await useCase.searchFDCFoodByString('apple');

        expect(result.meals, [customMatch]);
        expect(result.remoteSourceEmpty, isTrue);
      },
    );

    test(
      'returns empty meals + remoteSourceEmpty=true when remote fails and no '
      'custom meals match',
      () async {
        productsRepository.offThrowOn.add('xyzzy');
        getIntakeUsecase.recentIntake = const [];

        final result = await useCase.searchOFFProductsByString('xyzzy');

        expect(result.meals, isEmpty);
        expect(result.remoteSourceEmpty, isTrue);
      },
    );

    test(
      'remoteSourceEmpty=true when remote returns an empty list (not just on '
      'failure)',
      () async {
        final customMatch = _meal(
            code: 'custom-tofu',
            name: 'Tofu Bowl',
            source: MealSourceEntity.custom);

        // No offResults entry for 'tofu' → fake returns []
        getIntakeUsecase.recentIntake = [_intake('i1', customMatch)];

        final result = await useCase.searchOFFProductsByString('tofu');

        expect(result.meals, [customMatch]);
        expect(result.remoteSourceEmpty, isTrue);
      },
    );
  });
}

MealEntity _meal({
  required String code,
  required String name,
  required MealSourceEntity source,
}) {
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
    source: source,
  );
}

IntakeEntity _intake(String id, MealEntity meal) {
  return IntakeEntity(
    id: id,
    unit: 'g',
    amount: 100,
    type: IntakeTypeEntity.breakfast,
    meal: meal,
    dateTime: DateTime.utc(2024, 1, 1),
  );
}
