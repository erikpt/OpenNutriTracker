import 'dart:convert';
import 'dart:io' show gzip;

import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:opennutritracker/features/home/domain/entity/shared_meal_payload.dart';

void main() {
  MealEntity createMeal({
    required String code,
    required String name,
    String? brands,
    MealSourceEntity source = MealSourceEntity.custom,
    bool fullNutritionData = false,
  }) {
    return MealEntity(
      code: code,
      name: name,
      brands: brands,
      thumbnailImageUrl: fullNutritionData
          ? 'https://images.openfoodfacts.org/images/products/123/front.100.jpg'
          : null,
      mainImageUrl: fullNutritionData
          ? 'https://images.openfoodfacts.org/images/products/123/front.400.jpg'
          : null,
      url: null,
      mealQuantity: null,
      mealUnit: null,
      servingQuantity: null,
      servingUnit: null,
      servingSize: null,
      nutriments: fullNutritionData
          ? MealNutrimentsEntity(
              energyKcal100: 192.7,
              carbohydrates100: 22.0,
              fat100: 7.9,
              proteins100: 6.7,
              sugars100: 3.5,
              saturatedFat100: 2.6,
              fiber100: 2.0,
            )
          : MealNutrimentsEntity.empty(),
      source: source,
    );
  }

  IntakeEntity makeIntake(MealEntity meal, {int index = 0}) {
    return IntakeEntity(
      id: 'intake_$index',
      meal: meal,
      amount: 100 + index * 10.0,
      unit: 'g',
      dateTime: DateTime(2026, 4, 27),
      type: IntakeTypeEntity.breakfast,
    );
  }

  group('SharedMealPayload', () {
    // QR v40, error correction M: 3917 alphanumeric characters capacity
    const qrMaxChars = 3917;

    test('OFF items are encoded as 3-field barcode refs', () {
      final offMeal = createMeal(
        code: '4001724039143',
        name: 'Pizza Vegetale',
        brands: 'Dr. Oetker',
        source: MealSourceEntity.off,
        fullNutritionData: true,
      );
      final payload = SharedMealPayload.fromIntakeList([makeIntake(offMeal)]);

      expect(payload.offRefs.length, 1);
      expect(payload.items.length, 0);
      expect(payload.offRefs[0].barcode, '4001724039143');
      expect(payload.offRefs[0].amount, 100.0);
      expect(payload.offRefs[0].unit, 'g');
    });

    test('custom items are encoded as full-data arrays', () {
      final customMeal = createMeal(
        code: 'some-uuid',
        name: 'Homemade Soup',
        source: MealSourceEntity.custom,
        fullNutritionData: true,
      );
      final payload =
          SharedMealPayload.fromIntakeList([makeIntake(customMeal)]);

      expect(payload.offRefs.length, 0);
      expect(payload.items.length, 1);
      expect(payload.items[0].name, 'Homemade Soup');
    });

    test('round-trip preserves OFF refs and custom items', () {
      final intakes = [
        makeIntake(
          createMeal(
            code: '4001724039143',
            name: 'Pizza Vegetale',
            brands: 'Dr. Oetker',
            source: MealSourceEntity.off,
            fullNutritionData: true,
          ),
          index: 0,
        ),
        makeIntake(
          createMeal(
            code: 'some-uuid',
            name: 'Homemade Soup',
            source: MealSourceEntity.custom,
            fullNutritionData: true,
          ),
          index: 1,
        ),
      ];

      final encoded = SharedMealPayload.fromIntakeList(intakes).toJsonString();
      final decoded = SharedMealPayload.fromJsonString(encoded);

      expect(decoded.version, 1);
      expect(decoded.offRefs.length, 1);
      expect(decoded.offRefs[0].barcode, '4001724039143');
      expect(decoded.offRefs[0].amount, 100.0);
      expect(decoded.items.length, 1);
      expect(decoded.items[0].name, 'Homemade Soup');
      expect(decoded.items[0].energyKcal100, 192.7);
    });

    test('payloads for typical meal counts fit within QR v40/M capacity', () {
      // 5 OFF items: only barcodes stored — very small
      final offIntakes = List.generate(
        5,
        (i) => makeIntake(
          createMeal(
              code: '400172403914$i',
              name: 'Product $i',
              source: MealSourceEntity.off),
          index: i,
        ),
      );
      expect(
        SharedMealPayload.fromIntakeList(offIntakes).toJsonString().length,
        lessThan(qrMaxChars),
      );

      // 10 custom items with full nutritional data — worst case
      final customIntakes = List.generate(
        10,
        (i) => makeIntake(
          createMeal(
            code: 'uuid-$i',
            name: 'Meal Item $i',
            brands: 'Brand $i',
            source: MealSourceEntity.custom,
            fullNutritionData: true,
          ),
          index: i,
        ),
      );
      expect(
        SharedMealPayload.fromIntakeList(customIntakes).toJsonString().length,
        lessThan(qrMaxChars),
      );
    });

    test('unsupported version throws SharedMealParseException', () {
      final raw = base64Url.encode(gzip.encode(utf8.encode('[99,[],[]]')));
      expect(
        () => SharedMealPayload.fromJsonString(raw),
        throwsA(isA<SharedMealParseException>()),
      );
    });
  });
}
