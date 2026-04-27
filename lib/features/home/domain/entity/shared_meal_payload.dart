import 'dart:convert';
import 'dart:io' show gzip;

import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/utils/id_generator.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

class SharedMealParseException implements Exception {
  final String message;
  SharedMealParseException(this.message);
}

// Array field order: [name, brands, unit, amount, ec, cb, ft, pr, sg, sf, fb, thumbUrl, imgUrl]
class SharedMealItem {
  final String? name;
  final String? brands;
  final String unit;
  final double amount;
  final double? energyKcal100;
  final double? carbohydrates100;
  final double? fat100;
  final double? proteins100;
  final double? sugars100;
  final double? saturatedFat100;
  final double? fiber100;
  final String? thumbnailImageUrl;
  final String? mainImageUrl;

  const SharedMealItem({
    required this.name,
    required this.brands,
    required this.unit,
    required this.amount,
    required this.energyKcal100,
    required this.carbohydrates100,
    required this.fat100,
    required this.proteins100,
    required this.sugars100,
    required this.saturatedFat100,
    required this.fiber100,
    required this.thumbnailImageUrl,
    required this.mainImageUrl,
  });

  factory SharedMealItem.fromIntakeEntity(IntakeEntity intake) {
    return SharedMealItem(
      name: intake.meal.name,
      brands: intake.meal.brands,
      unit: intake.unit,
      amount: intake.amount,
      energyKcal100: intake.meal.nutriments.energyKcal100,
      carbohydrates100: intake.meal.nutriments.carbohydrates100,
      fat100: intake.meal.nutriments.fat100,
      proteins100: intake.meal.nutriments.proteins100,
      sugars100: intake.meal.nutriments.sugars100,
      saturatedFat100: intake.meal.nutriments.saturatedFat100,
      fiber100: intake.meal.nutriments.fiber100,
      thumbnailImageUrl: intake.meal.thumbnailImageUrl,
      mainImageUrl: intake.meal.mainImageUrl,
    );
  }

  factory SharedMealItem.fromArray(List<dynamic> a) {
    num? atNum(int i) => a.length > i ? a[i] as num? : null;
    String? atStr(int i) => a.length > i ? a[i] as String? : null;
    return SharedMealItem(
      name: a[0] as String?,
      brands: a[1] as String?,
      unit: (a[2] as String?) ?? 'g',
      amount: (a[3] as num?)?.toDouble() ?? 100.0,
      energyKcal100: atNum(4)?.toDouble(),
      carbohydrates100: atNum(5)?.toDouble(),
      fat100: atNum(6)?.toDouble(),
      proteins100: atNum(7)?.toDouble(),
      sugars100: atNum(8)?.toDouble(),
      saturatedFat100: atNum(9)?.toDouble(),
      fiber100: atNum(10)?.toDouble(),
      thumbnailImageUrl: atStr(11),
      mainImageUrl: atStr(12),
    );
  }

  // Legacy map format (v1 object encoding) — decode only
  factory SharedMealItem.fromMap(Map<String, dynamic> map) {
    return SharedMealItem(
      name: map['n'] as String?,
      brands: map['br'] as String?,
      unit: (map['u'] as String?) ?? 'g',
      amount: (map['a'] as num?)?.toDouble() ?? 100.0,
      energyKcal100: (map['ec'] as num?)?.toDouble(),
      carbohydrates100: (map['cb'] as num?)?.toDouble(),
      fat100: (map['ft'] as num?)?.toDouble(),
      proteins100: (map['pr'] as num?)?.toDouble(),
      sugars100: (map['sg'] as num?)?.toDouble(),
      saturatedFat100: (map['sf'] as num?)?.toDouble(),
      fiber100: (map['fb'] as num?)?.toDouble(),
      thumbnailImageUrl: null,
      mainImageUrl: null,
    );
  }

  List<dynamic> toArray() {
    return [
      name,
      brands,
      unit,
      _compact(amount),
      _compact(energyKcal100),
      _compact(carbohydrates100),
      _compact(fat100),
      _compact(proteins100),
      _compact(sugars100),
      _compact(saturatedFat100),
      _compact(fiber100),
      thumbnailImageUrl,
      mainImageUrl,
    ];
  }

  // Emit int for whole numbers, round to 1dp otherwise — shrinks JSON before compression
  static num? _compact(double? v) {
    if (v == null) return null;
    if (v == v.truncateToDouble()) return v.toInt();
    return double.parse(v.toStringAsFixed(1));
  }

  MealEntity toMealEntity() {
    return MealEntity(
      code: IdGenerator.getUniqueID(),
      name: name,
      brands: brands,
      thumbnailImageUrl: thumbnailImageUrl,
      mainImageUrl: mainImageUrl,
      url: null,
      mealQuantity: null,
      mealUnit: null,
      servingQuantity: null,
      servingUnit: null,
      servingSize: null,
      nutriments: MealNutrimentsEntity(
        energyKcal100: energyKcal100,
        carbohydrates100: carbohydrates100,
        fat100: fat100,
        proteins100: proteins100,
        sugars100: sugars100,
        saturatedFat100: saturatedFat100,
        fiber100: fiber100,
      ),
      source: MealSourceEntity.custom,
    );
  }
}

class SharedMealPayload {
  static const int _currentVersion = 2;

  final int version;
  final List<SharedMealItem> items;

  const SharedMealPayload({required this.version, required this.items});

  factory SharedMealPayload.fromIntakeList(List<IntakeEntity> intakes) {
    return SharedMealPayload(
      version: _currentVersion,
      items: intakes.map(SharedMealItem.fromIntakeEntity).toList(),
    );
  }

  factory SharedMealPayload.fromJsonString(String input) {
    try {
      String jsonString;
      try {
        jsonString = utf8.decode(gzip.decode(base64Url.decode(base64Url.normalize(input))));
      } catch (_) {
        jsonString = input;
      }

      final decoded = jsonDecode(jsonString);

      if (decoded is List) {
        // v2 array format: [version, [[item arrays...]]]
        final version = decoded[0] as int;
        if (version > _currentVersion) {
          throw SharedMealParseException('Unsupported payload version: $version');
        }
        final rawItems = decoded[1] as List<dynamic>;
        final items = rawItems.map((e) => SharedMealItem.fromArray(e as List<dynamic>)).toList();
        return SharedMealPayload(version: version, items: items);
      } else {
        // v1 legacy map format
        final map = decoded as Map<String, dynamic>;
        final version = map['v'] as int?;
        if (version == null || version > _currentVersion) {
          throw SharedMealParseException('Unsupported payload version: $version');
        }
        final rawItems = map['items'] as List<dynamic>?;
        if (rawItems == null) throw SharedMealParseException('Missing items field');
        final items = rawItems.map((e) => SharedMealItem.fromMap(e as Map<String, dynamic>)).toList();
        return SharedMealPayload(version: version, items: items);
      }
    } on SharedMealParseException {
      rethrow;
    } catch (e) {
      throw SharedMealParseException('Failed to parse payload: $e');
    }
  }

  String toJsonString() {
    final json = jsonEncode([version, items.map((i) => i.toArray()).toList()]);
    return base64Url.encode(gzip.encode(utf8.encode(json)));
  }

  List<MealEntity> toMealEntities() {
    return items.map((i) => i.toMealEntity()).toList();
  }
}
