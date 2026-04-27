import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:opennutritracker/features/home/domain/entity/shared_meal_payload.dart';

void main() {
  MealEntity createTestMeal({
    required String code,
    required String name,
    String? brands,
    bool fullNutritionData = false,
  }) {
    return MealEntity(
      code: code,
      name: name,
      brands: brands,
      thumbnailImageUrl: fullNutritionData ? 'https://example.com/thumb.jpg' : null,
      mainImageUrl: fullNutritionData ? 'https://example.com/main.jpg' : null,
      url: null,
      mealQuantity: null,
      mealUnit: null,
      servingQuantity: null,
      servingUnit: null,
      servingSize: null,
      nutriments: fullNutritionData
          ? MealNutrimentsEntity(
              energyKcal100: 100.5,
              carbohydrates100: 50.2,
              fat100: 25.1,
              proteins100: 20.0,
              sugars100: 10.0,
              saturatedFat100: 5.0,
              fiber100: 3.0,
            )
          : MealNutrimentsEntity.empty(),
      source: MealSourceEntity.custom,
    );
  }

  List<IntakeEntity> createIntakes(List<MealEntity> meals) {
    return meals
        .asMap()
        .entries
        .map((e) => IntakeEntity(
              id: 'intake_${e.key}',
              meal: e.value,
              amount: 100 + e.key * 10,
              unit: 'g',
              dateTime: DateTime.now().subtract(Duration(days: e.key)),
              type: IntakeTypeEntity.breakfast,
            ))
        .toList();
  }

  group('SharedMealPayload', () {
    // QR v40, error correction M: 3917 alphanumeric characters capacity
    const qrMaxChars = 3917;

    test('payloads for typical meal counts fit within QR v40/M capacity', () {
      final payload1 = SharedMealPayload.fromIntakeList(
        createIntakes([createTestMeal(code: '1', name: 'Apple')]),
      );
      expect(payload1.toJsonString().length, lessThan(qrMaxChars));

      final meals5 = List.generate(
        5,
        (i) => createTestMeal(code: '$i', name: 'Meal $i', brands: 'Brand $i', fullNutritionData: true),
      );
      expect(
        SharedMealPayload.fromIntakeList(createIntakes(meals5)).toJsonString().length,
        lessThan(qrMaxChars),
      );

      final meals10 = List.generate(
        10,
        (i) => createTestMeal(code: '$i', name: 'Meal Item $i', brands: 'Brand Name $i', fullNutritionData: true),
      );
      expect(
        SharedMealPayload.fromIntakeList(createIntakes(meals10)).toJsonString().length,
        lessThan(qrMaxChars),
      );
    });

    test('round-trip encoding/decoding preserves data integrity', () {
      final meals = [
        createTestMeal(code: '1', name: 'Complex Meal Name', brands: 'Complex Brand', fullNutritionData: true),
        createTestMeal(code: '2', name: 'Simple', fullNutritionData: false),
      ];
      final intakes = createIntakes(meals);
      final original = SharedMealPayload.fromIntakeList(intakes);

      final encoded = original.toJsonString();
      final decoded = SharedMealPayload.fromJsonString(encoded);

      expect(decoded.version, original.version);
      expect(decoded.items.length, original.items.length);
      expect(decoded.items[0].name, 'Complex Meal Name');
      expect(decoded.items[0].brands, 'Complex Brand');
      expect(decoded.items[0].energyKcal100, 100.5);
    });
  });
}
