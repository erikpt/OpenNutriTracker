import 'dart:convert';
import 'dart:io' show gzip;

import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:opennutritracker/features/home/domain/entity/shared_meal_payload.dart';

void main() {
  group('SharedMealPayload - Compression & QR Capacity Analysis', () {
    /// Creates a test meal with optional full nutritional data
    MealEntity _createTestMeal({
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

    /// Creates test intakes from meals
    List<IntakeEntity> _createIntakes(List<MealEntity> meals) {
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

    test('Comprehensive payload size analysis', () {
      /// QR Code Capacity Reference (Version 40, M Error Correction)
      const qrMaxCapacityBytes = 2953;
      const qrMaxCapacityBase64Chars = 3937;

      void _logCompression(String testName, int itemCount, String jsonString, String qrPayload) {
        final jsonBytes = utf8.encode(jsonString);
        final gzipBytes = gzip.encode(jsonBytes);
        final base64Chars = qrPayload.length;

        final compressionRatio = gzipBytes.length / jsonBytes.length;
        final capacityPercent = (base64Chars / qrMaxCapacityBase64Chars * 100).toStringAsFixed(1);
        final remaining = qrMaxCapacityBase64Chars - base64Chars;

        print('');
        print('┌──────────────────────────────────────────────────────────┐');
        print('│ $testName');
        print('├──────────────────────────────────────────────────────────┤');
        print('│ Items: $itemCount');
        print('│ Raw JSON: ${jsonBytes.length} bytes');
        print('│ Gzipped: ${gzipBytes.length} bytes (ratio: ${(compressionRatio * 100).toStringAsFixed(1)}%)');
        print('│ Base64 encoded: $base64Chars characters');
        print('│ QR capacity used: $capacityPercent%');
        print('│ Remaining for more items: $remaining characters');
        if (base64Chars >= qrMaxCapacityBase64Chars) {
          print('│ ⚠️  EXCEEDS QR v40 CAPACITY!');
        }
        print('└──────────────────────────────────────────────────────────┘');
      }

      // Test 1: Minimal item
      final meal1 = _createTestMeal(code: '1', name: 'Apple', fullNutritionData: false);
      final intake1 = _createIntakes([meal1]);
      final payload1 = SharedMealPayload.fromIntakeList(intake1);
      final qr1 = payload1.toJsonString();
      _logCompression('1 item (minimal)', 1, 
          jsonEncode([payload1.version, payload1.items.map((i) => i.toArray()).toList()]),
          qr1);

      // Test 2: 5 items mixed density
      final meals5 = [
        _createTestMeal(code: '1', name: 'Apple', fullNutritionData: false),
        _createTestMeal(code: '2', name: 'Banana with longer name', brands: 'Fresh Organic', fullNutritionData: true),
        _createTestMeal(code: '3', name: 'Oats', fullNutritionData: false),
        _createTestMeal(code: '4', name: 'Almond Milk', brands: 'Dairy Brand Name', fullNutritionData: true),
        _createTestMeal(code: '5', name: 'Honey', fullNutritionData: false),
      ];
      final intake5 = _createIntakes(meals5);
      final payload5 = SharedMealPayload.fromIntakeList(intake5);
      final qr5 = payload5.toJsonString();
      _logCompression('5 items (mixed)', 5,
          jsonEncode([payload5.version, payload5.items.map((i) => i.toArray()).toList()]),
          qr5);

      // Test 3: 10 items all with full data
      final meals10 = List.generate(
        10,
        (i) => _createTestMeal(
          code: '$i',
          name: 'Meal Item Number $i',
          brands: 'Brand Name $i Extended',
          fullNutritionData: true,
        ),
      );
      final intake10 = _createIntakes(meals10);
      final payload10 = SharedMealPayload.fromIntakeList(intake10);
      final qr10 = payload10.toJsonString();
      _logCompression('10 items (full data)', 10,
          jsonEncode([payload10.version, payload10.items.map((i) => i.toArray()).toList()]),
          qr10);

      // Test 4: 15 items
      final meals15 = List.generate(
        15,
        (i) => _createTestMeal(
          code: '$i',
          name: 'Food Item $i',
          brands: 'Brand $i',
          fullNutritionData: true,
        ),
      );
      final intake15 = _createIntakes(meals15);
      final payload15 = SharedMealPayload.fromIntakeList(intake15);
      final qr15 = payload15.toJsonString();
      _logCompression('15 items (full data)', 15,
          jsonEncode([payload15.version, payload15.items.map((i) => i.toArray()).toList()]),
          qr15);

      // Test 5: 20 items
      final meals20 = List.generate(
        20,
        (i) => _createTestMeal(
          code: '$i',
          name: 'Item $i',
          brands: 'Brand $i',
          fullNutritionData: true,
        ),
      );
      final intake20 = _createIntakes(meals20);
      final payload20 = SharedMealPayload.fromIntakeList(intake20);
      final qr20 = payload20.toJsonString();
      _logCompression('20 items (full data)', 20,
          jsonEncode([payload20.version, payload20.items.map((i) => i.toArray()).toList()]),
          qr20);

      // Summary table
      print('');
      print('╔════════════════════════════════════════════════════════════╗');
      print('║                    CAPACITY SUMMARY                        ║');
      print('╠═══════════╦════════════════╦═══════════════╦════════════════╣');
      print('║  Items    ║  Base64 Chars  ║  QR Usage     ║  Can Add More? ║');
      print('╠═══════════╬════════════════╬═══════════════╬════════════════╣');
      print('║     1     ║  ${qr1.length.toString().padLeft(12)} ║  ${((qr1.length / qrMaxCapacityBase64Chars * 100).toStringAsFixed(1) + '%').padLeft(11)} ║  ✅ Yes       ║');
      print('║     5     ║  ${qr5.length.toString().padLeft(12)} ║  ${((qr5.length / qrMaxCapacityBase64Chars * 100).toStringAsFixed(1) + '%').padLeft(11)} ║  ✅ Yes       ║');
      print('║    10     ║  ${qr10.length.toString().padLeft(12)} ║  ${((qr10.length / qrMaxCapacityBase64Chars * 100).toStringAsFixed(1) + '%').padLeft(11)} ║  ✅ Yes       ║');
      print('║    15     ║  ${qr15.length.toString().padLeft(12)} ║  ${((qr15.length / qrMaxCapacityBase64Chars * 100).toStringAsFixed(1) + '%').padLeft(11)} ║  ${(qr15.length >= qrMaxCapacityBase64Chars ? '❌ No' : '✅ Yes').padRight(10)} ║');
      print('║    20     ║  ${qr20.length.toString().padLeft(12)} ║  ${((qr20.length / qrMaxCapacityBase64Chars * 100).toStringAsFixed(1) + '%').padLeft(11)} ║  ${(qr20.length >= qrMaxCapacityBase64Chars ? '❌ No' : '✅ Yes').padRight(10)} ║');
      print('╚═══════════╩════════════════╩═══════════════╩════════════════╝');

      expect(qr1.length, lessThan(qrMaxCapacityBase64Chars));
      expect(qr5.length, lessThan(qrMaxCapacityBase64Chars));
      expect(qr10.length, lessThan(qrMaxCapacityBase64Chars));
    });

    test('Round-trip encoding/decoding preserves data integrity', () {
      final meals = [
        _createTestMeal(code: '1', name: 'Complex Meal Name', brands: 'Complex Brand', fullNutritionData: true),
        _createTestMeal(code: '2', name: 'Simple', fullNutritionData: false),
      ];
      final intakes = _createIntakes(meals);
      final original = SharedMealPayload.fromIntakeList(intakes);

      // Encode and decode
      final encoded = original.toJsonString();
      final decoded = SharedMealPayload.fromJsonString(encoded);

      // Verify
      expect(decoded.version, original.version);
      expect(decoded.items.length, original.items.length);
      expect(decoded.items[0].name, 'Complex Meal Name');
      expect(decoded.items[0].brands, 'Complex Brand');
      expect(decoded.items[0].energyKcal100, 100.5);
    });
  });
}
