import 'dart:io';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:opennutritracker/core/data/dbo/meal_dbo.dart';

/// Local cache of remote meal lookups (Open Food Facts AND Supabase FDC).
/// Every successful network search or barcode lookup writes its result
/// here so that subsequent searches and scans for the same product
/// resolve from disk — fast, and works offline.
///
/// Cached entries keep their original [MealSourceDBO] (`off` / `fdc`);
/// they are NOT custom meals, just a local mirror of the remote result
/// we last saw. This is separate from `CustomMealBox` so the user's own
/// meals stay distinct from cached remote data and can be deleted
/// independently.
///
/// The on-disk box name (`CachedOffMealBox`) is kept for backward
/// compatibility with installs that already have data in it; only the
/// Dart class name was generalised when FDC caching was added.
class RemoteSearchCacheDataSource {
  final Box<MealDBO> _cacheBox;

  RemoteSearchCacheDataSource(this._cacheBox);

  /// Persist [meal] in the cache. If a cached entry with the same code
  /// (or, when code is null, the same name) already exists, it is
  /// overwritten so the freshest remote result wins.
  Future<void> cache(MealDBO meal) async {
    final existing = _cacheBox.values.cast<MealDBO?>().firstWhere(
      (m) =>
          (meal.code != null && m?.code == meal.code) ||
          (meal.code == null && m?.name == meal.name),
      orElse: () => null,
    );
    if (existing != null) {
      await _cacheBox.put(existing.key, meal);
    } else {
      await _cacheBox.add(meal);
    }
  }

  /// Persist all of [meals] in one pass.
  Future<void> cacheAll(Iterable<MealDBO> meals) async {
    for (final meal in meals) {
      await cache(meal);
    }
  }

  List<MealDBO> getAll() => _cacheBox.values.toList();

  /// Look up a single cached meal by barcode. Returns null when none
  /// matches — the caller should then fall back to the remote API.
  MealDBO? getByBarcode(String barcode) {
    for (final meal in _cacheBox.values) {
      if (meal.code == barcode) return meal;
    }
    return null;
  }

  int get count => _cacheBox.length;

  /// On-disk size of the cache box in bytes. Returns 0 when the box file
  /// hasn't been flushed yet or the path can't be statted (e.g. in tests
  /// running on an in-memory Hive). Used by Settings to show how much
  /// space the cache is occupying.
  Future<int> getStorageSizeBytes() async {
    final path = _cacheBox.path;
    if (path == null) return 0;
    final file = File(path);
    if (!await file.exists()) return 0;
    return file.length();
  }

  Future<void> clear() => _cacheBox.clear();
}
