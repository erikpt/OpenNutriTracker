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

// Emit int for whole numbers, round to 1dp otherwise — shrinks JSON before compression
num? _compact(double? v) {
  if (v == null) return null;
  if (v == v.truncateToDouble()) return v.toInt();
  return double.parse(v.toStringAsFixed(1));
}

// OFF ref field order: [barcode, amount, unit]
class SharedMealOffRef {
  final String barcode;
  final double amount;
  final String unit;

  const SharedMealOffRef(
      {required this.barcode, required this.amount, required this.unit});

  factory SharedMealOffRef.fromIntakeEntity(IntakeEntity intake) {
    return SharedMealOffRef(
      barcode: intake.meal.code!,
      amount: intake.amount,
      unit: intake.unit,
    );
  }

  factory SharedMealOffRef.fromArray(List<dynamic> a) {
    return SharedMealOffRef(
      barcode: a[0] as String,
      amount: (a[1] as num).toDouble(),
      unit: (a[2] as String?) ?? 'g',
    );
  }

  List<dynamic> toArray() => [barcode, _compact(amount), unit];
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
  static const int _currentVersion = 1;

  final int version;
  final List<SharedMealOffRef> offRefs;
  final List<SharedMealItem> items;

  int get totalCount => offRefs.length + items.length;

  const SharedMealPayload(
      {required this.version, required this.offRefs, required this.items});

  factory SharedMealPayload.fromIntakeList(List<IntakeEntity> intakes) {
    return SharedMealPayload(
      version: _currentVersion,
      offRefs: intakes
          .where((i) =>
              i.meal.source == MealSourceEntity.off && i.meal.code != null)
          .map(SharedMealOffRef.fromIntakeEntity)
          .toList(),
      items: intakes
          .where((i) =>
              i.meal.source != MealSourceEntity.off || i.meal.code == null)
          .map(SharedMealItem.fromIntakeEntity)
          .toList(),
    );
  }

  factory SharedMealPayload.fromJsonString(String input) {
    try {
      String jsonString;
      try {
        jsonString = utf8
            .decode(gzip.decode(base64Url.decode(base64Url.normalize(input))));
      } catch (_) {
        jsonString = input;
      }

      final decoded = jsonDecode(jsonString);
      if (decoded is! List) throw SharedMealParseException('Invalid payload format');

      final version = decoded[0] as int;
      if (version != _currentVersion) {
        throw SharedMealParseException('Unsupported payload version: $version');
      }

      final rawOffRefs = decoded[1] as List<dynamic>;
      final rawItems = decoded[2] as List<dynamic>;
      return SharedMealPayload(
        version: version,
        offRefs: rawOffRefs
            .map((e) => SharedMealOffRef.fromArray(e as List<dynamic>))
            .toList(),
        items: rawItems
            .map((e) => SharedMealItem.fromArray(e as List<dynamic>))
            .toList(),
      );
    } on SharedMealParseException {
      rethrow;
    } catch (e) {
      throw SharedMealParseException('Failed to parse payload: $e');
    }
  }

  String toJsonString() {
    final json = jsonEncode([
      version,
      offRefs.map((r) => r.toArray()).toList(),
      items.map((i) => i.toArray()).toList(),
    ]);
    return base64Url.encode(gzip.encode(utf8.encode(json)));
  }

  List<MealEntity> toMealEntities() =>
      items.map((i) => i.toMealEntity()).toList();
}
