import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/features/add_meal/data/dto/fdc/fdc_const.dart';
import 'package:opennutritracker/features/add_meal/data/dto/fdc/fdc_food_nutriment_dto.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

void main() {
  group('MealNutrimentsEntity.fromFDCNutriments', () {
    group('Issue #252 - Energy value parsing', () {
      test('should prefer Atwater Specific Factors when available', () {
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcKcalAtwaterSpecificId, amount: 250.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcKcalAtwaterGeneralId, amount: 240.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalKcalId, amount: 230.0),
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.energyKcal100, 250.0,
            reason: 'Should prefer Atwater Specific Factors (958)');
      });

      test('should fallback to Atwater General Factors when Specific not available', () {
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcKcalAtwaterGeneralId, amount: 240.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalKcalId, amount: 230.0),
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.energyKcal100, 240.0,
            reason: 'Should use Atwater General Factors (957) as fallback');
      });

      test('should fallback to Total Energy when Atwater values not available', () {
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalKcalId, amount: 230.0),
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.energyKcal100, 230.0,
            reason: 'Should use Total Energy (1008) as final fallback');
      });

      test('should return null when no energy value available', () {
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalCarbsId, amount: 50.0),
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.energyKcal100, null,
            reason: 'Should return null when no energy values present');
      });
    });

    group('Issue #222 - Data validation', () {
      test('should reject negative values', () {
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalKcalId, amount: -50.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalCarbsId, amount: -20.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalFatId, amount: -10.0),
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.energyKcal100, null,
            reason: 'Should reject negative energy');
        expect(entity.carbohydrates100, null,
            reason: 'Should reject negative carbs');
        expect(entity.fat100, null, reason: 'Should reject negative fat');
      });

      test('should reject unrealistic energy values (>900 kcal per 100g)', () {
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalKcalId, amount: 950.0),
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.energyKcal100, null,
            reason: 'Should reject energy values exceeding 900 kcal per 100g');
      });

      test('should reject macro values exceeding 100g per 100g', () {
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalCarbsId, amount: 120.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalFatId, amount: 110.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalProteinsId, amount: 105.0),
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.carbohydrates100, null,
            reason: 'Should reject carbs > 100g per 100g');
        expect(entity.fat100, null, reason: 'Should reject fat > 100g per 100g');
        expect(entity.proteins100, null,
            reason: 'Should reject proteins > 100g per 100g');
      });

      test('should reject sugar exceeding carbohydrates', () {
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalCarbsId, amount: 50.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalSugarId, amount: 60.0),
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.carbohydrates100, 50.0,
            reason: 'Carbs value should be valid');
        expect(entity.sugars100, null,
            reason: 'Should reject sugar > carbohydrates');
      });

      test('should reject saturated fat exceeding total fat', () {
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalFatId, amount: 20.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalSaturatedFatId, amount: 25.0),
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.fat100, 20.0, reason: 'Fat value should be valid');
        expect(entity.saturatedFat100, null,
            reason: 'Should reject saturated fat > total fat');
      });

      test('should reject fiber exceeding carbohydrates', () {
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalCarbsId, amount: 30.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalDietaryFiberId, amount: 35.0),
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.carbohydrates100, 30.0,
            reason: 'Carbs value should be valid');
        expect(entity.fiber100, null,
            reason: 'Should reject fiber > carbohydrates');
      });

      test('should accept valid nutritional data', () {
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcKcalAtwaterSpecificId, amount: 250.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalCarbsId, amount: 50.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalFatId, amount: 10.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalProteinsId, amount: 8.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalSugarId, amount: 25.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalSaturatedFatId, amount: 5.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalDietaryFiberId, amount: 3.0),
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.energyKcal100, 250.0);
        expect(entity.carbohydrates100, 50.0);
        expect(entity.fat100, 10.0);
        expect(entity.proteins100, 8.0);
        expect(entity.sugars100, 25.0);
        expect(entity.saturatedFat100, 5.0);
        expect(entity.fiber100, 3.0);
      });

      test('should handle missing optional nutrients gracefully', () {
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalKcalId, amount: 100.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalCarbsId, amount: 20.0),
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.energyKcal100, 100.0);
        expect(entity.carbohydrates100, 20.0);
        expect(entity.fat100, null);
        expect(entity.proteins100, null);
        expect(entity.sugars100, null);
        expect(entity.saturatedFat100, null);
        expect(entity.fiber100, null);
      });

      test('should validate sub-nutrients when parent nutrient is missing', () {
        // When carbs are missing but sugar/fiber are present, validate against max macro limit
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalSugarId, amount: 50.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalDietaryFiberId, amount: 30.0),
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.carbohydrates100, null);
        expect(entity.sugars100, 50.0, 
            reason: 'Sugar should be valid when carbs missing but value reasonable');
        expect(entity.fiber100, 30.0,
            reason: 'Fiber should be valid when carbs missing but value reasonable');
      });

      test('should reject sub-nutrients exceeding max when parent nutrient is missing', () {
        // When carbs are missing but sugar/fiber exceed max macro limit, reject them
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalSugarId, amount: 150.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalDietaryFiberId, amount: 120.0),
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.carbohydrates100, null);
        expect(entity.sugars100, null,
            reason: 'Sugar should be rejected when exceeds max even if carbs missing');
        expect(entity.fiber100, null,
            reason: 'Fiber should be rejected when exceeds max even if carbs missing');
      });

      test('should handle edge case: fiber = carbohydrates (valid)', () {
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalCarbsId, amount: 30.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalDietaryFiberId, amount: 30.0),
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.carbohydrates100, 30.0);
        expect(entity.fiber100, 30.0,
            reason: 'Fiber equal to carbs should be valid');
      });

      test('should handle edge case: values at boundaries', () {
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalKcalId, amount: 900.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalCarbsId, amount: 100.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalFatId, amount: 100.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalProteinsId, amount: 100.0),
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.energyKcal100, 900.0, reason: 'Max energy should be valid');
        expect(entity.carbohydrates100, 100.0, reason: 'Max carbs should be valid');
        expect(entity.fat100, 100.0, reason: 'Max fat should be valid');
        expect(entity.proteins100, 100.0, reason: 'Max proteins should be valid');
      });
    });

    group('Real-world FDC data examples', () {
      test('should handle apple with nonsensical sugar and fiber values (issue #222 example)', () {
        // Simulating the apple data from issue #222 where sugar and fiber were 20x too high
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcKcalAtwaterSpecificId, amount: 52.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalCarbsId, amount: 14.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalSugarId, amount: 280.0), // 20x error - exceeds carbs
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalDietaryFiberId, amount: 280.0), // 20x error - exceeds carbs
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.energyKcal100, 52.0, reason: 'Energy should be valid');
        expect(entity.carbohydrates100, 14.0, reason: 'Carbs should be valid');
        expect(entity.sugars100, null,
            reason: 'Should reject nonsensical sugar value');
        expect(entity.fiber100, null,
            reason: 'Should reject nonsensical fiber value');
      });

      test('should handle bread with missing energy fallback correctly', () {
        // Simulating "Bread, whole-wheat, commercial" from issue #252
        final fdcNutriments = [
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcKcalAtwaterGeneralId, amount: 247.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalCarbsId, amount: 41.0),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalFatId, amount: 3.5),
          FDCFoodNutrimentDTO(
              nutrientId: FDCConst.fdcTotalProteinsId, amount: 13.0),
        ];

        final entity = MealNutrimentsEntity.fromFDCNutriments(fdcNutriments);

        expect(entity.energyKcal100, 247.0,
            reason: 'Should use Atwater General as fallback');
        expect(entity.carbohydrates100, 41.0);
        expect(entity.fat100, 3.5);
        expect(entity.proteins100, 13.0);
      });
    });
  });
}
