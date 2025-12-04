import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/dbo/tracked_day_dbo.dart';
import 'package:opennutritracker/core/utils/extensions.dart';

class TrackedDayDataSource {
  final log = Logger('TrackedDayDataSource');
  final Box<TrackedDayDBO> _trackedDayBox;

  TrackedDayDataSource(this._trackedDayBox);

  /// Migrates tracked days from old date format (locale-dependent yMd) to new ISO 8601 format (yyyy-MM-dd)
  /// This ensures backward compatibility with existing data while preventing future data loss
  Future<void> migrateToNewDateFormat() async {
    log.info('Starting tracked day date format migration...');
    
    try {
      final allKeys = _trackedDayBox.keys.toList();
      final newFormatRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$'); // Matches yyyy-MM-dd
      int migratedCount = 0;

      for (final key in allKeys) {
        final keyString = key.toString();
        
        // Skip if already in new format
        if (newFormatRegex.hasMatch(keyString)) {
          continue;
        }

        final trackedDay = _trackedDayBox.get(key);
        if (trackedDay != null) {
          // Generate new key using the date stored in the object
          final newKey = trackedDay.day.toParsedDay();
          
          // Only migrate if new key doesn't already exist (avoid overwriting)
          if (!_trackedDayBox.containsKey(newKey)) {
            await _trackedDayBox.put(newKey, trackedDay);
            await _trackedDayBox.delete(key);
            migratedCount++;
            log.fine('Migrated key: $keyString -> $newKey');
          } else {
            log.warning('Skipping migration for $keyString: new key $newKey already exists');
          }
        }
      }

      if (migratedCount > 0) {
        log.info('Migration complete: $migratedCount tracked day(s) migrated to new format');
      } else {
        log.info('No migration needed: all tracked days already use new format');
      }
    } catch (e, stackTrace) {
      log.severe('Error during tracked day migration: $e', e, stackTrace);
      rethrow;
    }
  }

  Future<void> saveTrackedDay(TrackedDayDBO trackedDayDBO) async {
    log.fine('Updating tracked day in db');
    _trackedDayBox.put(trackedDayDBO.day.toParsedDay(), trackedDayDBO);
  }

  Future<void> saveAllTrackedDays(List<TrackedDayDBO> trackedDayDBOList) async {
    log.fine('Updating tracked days in db');
    _trackedDayBox.putAll({
      for (var trackedDayDBO in trackedDayDBOList)
        trackedDayDBO.day.toParsedDay(): trackedDayDBO
    });
  }

  Future<List<TrackedDayDBO>> getAllTrackedDays() async {
    return _trackedDayBox.values.toList();
  }

  Future<TrackedDayDBO?> getTrackedDay(DateTime day) async {
    return _trackedDayBox.get(day.toParsedDay());
  }

  Future<List<TrackedDayDBO>> getTrackedDaysInRange(
      DateTime start, DateTime end) async {
    List<TrackedDayDBO> trackedDays = _trackedDayBox.values
        .where((trackedDay) =>
            !trackedDay.day.isBefore(start) && !trackedDay.day.isAfter(end))
        .toList();
    return trackedDays;
  }

  Future<bool> hasTrackedDay(DateTime day) async =>
      _trackedDayBox.get(day.toParsedDay()) != null;

  Future<void> updateDayCalorieGoal(DateTime day, double calorieGoal) async {
    log.fine('Updating tracked day total calories');
    final updateDay = await getTrackedDay(day);

    if (updateDay != null) {
      updateDay.calorieGoal = calorieGoal;
      updateDay.save();
    }
  }

  Future<void> increaseDayCalorieGoal(DateTime day, double amount) async {
    log.fine('Increasing tracked day total calories');
    final updateDay = await getTrackedDay(day);

    if (updateDay != null) {
      updateDay.calorieGoal += amount;
      updateDay.save();
    }
  }

  Future<void> reduceDayCalorieGoal(DateTime day, double amount) async {
    log.fine('Reducing tracked day total calories');
    final updateDay = await getTrackedDay(day);

    if (updateDay != null) {
      updateDay.calorieGoal -= amount;
      updateDay.save();
    }
  }

  Future<void> addDayCaloriesTracked(DateTime day, double addCalories) async {
    log.fine('Adding new tracked day calories');
    final updateDay = await getTrackedDay(day);

    if (updateDay != null) {
      updateDay.caloriesTracked += addCalories;
      updateDay.save();
    }
  }

  Future<void> decreaseDayCaloriesTracked(
      DateTime day, double addCalories) async {
    log.fine('Decreasing tracked day calories');
    final updateDay = await getTrackedDay(day);

    if (updateDay != null) {
      final newValue = updateDay.caloriesTracked - addCalories;
      updateDay.caloriesTracked = newValue < 0 ? 0 : newValue;
      updateDay.save();
    }
  }

  Future<void> updateDayMacroGoals(DateTime day,
      {double? carbsGoal, double? fatGoal, double? proteinGoal}) async {
    log.fine('Updating tracked day macro goals');

    final updateDay = await getTrackedDay(day);

    if (updateDay != null) {
      if (carbsGoal != null) {
        updateDay.carbsGoal = carbsGoal;
      }
      if (fatGoal != null) {
        updateDay.fatGoal = fatGoal;
      }
      if (proteinGoal != null) {
        updateDay.proteinGoal = proteinGoal;
      }
      updateDay.save();
    }
  }

  Future<void> increaseDayMacroGoal(DateTime day,
      {double? carbsAmount, double? fatAmount, double? proteinAmount}) async {
    log.fine('Increasing tracked day macro goals');
    final updateDay = await getTrackedDay(day);

    if (updateDay != null) {
      if (carbsAmount != null) {
        updateDay.carbsGoal = (updateDay.carbsGoal ?? 0) + carbsAmount;
      }
      if (fatAmount != null) {
        updateDay.fatGoal = (updateDay.fatGoal ?? 0) + fatAmount;
      }
      if (proteinAmount != null) {
        updateDay.proteinGoal = (updateDay.proteinGoal ?? 0) + proteinAmount;
      }
      updateDay.save();
    }
  }

  Future<void> reduceDayMacroGoal(DateTime day,
      {double? carbsAmount, double? fatAmount, double? proteinAmount}) async {
    log.fine('Reducing tracked day macro goals');
    final updateDay = await getTrackedDay(day);

    if (updateDay != null) {
      if (carbsAmount != null) {
        updateDay.carbsGoal = (updateDay.carbsGoal ?? 0) - carbsAmount;
      }
      if (fatAmount != null) {
        updateDay.fatGoal = (updateDay.fatGoal ?? 0) - fatAmount;
      }
      if (proteinAmount != null) {
        updateDay.proteinGoal = (updateDay.proteinGoal ?? 0) - proteinAmount;
      }
      updateDay.save();
    }
  }

  Future<void> addDayMacroTracked(DateTime day,
      {double? carbsAmount, double? fatAmount, double? proteinAmount}) async {
    log.fine('Adding new tracked day macro');
    final updateDay = await getTrackedDay(day);

    if (updateDay != null) {
      if (carbsAmount != null) {
        updateDay.carbsTracked = (updateDay.carbsTracked ?? 0) + carbsAmount;
      }
      if (fatAmount != null) {
        updateDay.fatTracked = (updateDay.fatTracked ?? 0) + fatAmount;
      }
      if (proteinAmount != null) {
        updateDay.proteinTracked =
            (updateDay.proteinTracked ?? 0) + proteinAmount;
      }
      updateDay.save();
    }
  }

  Future<void> removeDayMacroTracked(DateTime day,
      {double? carbsAmount, double? fatAmount, double? proteinAmount}) async {
    log.fine('Removing tracked day macro');
    final updateDay = await getTrackedDay(day);

    if (updateDay != null) {
      if (carbsAmount != null) {
        final newValue = (updateDay.carbsTracked ?? 0) - carbsAmount;
        updateDay.carbsTracked = newValue < 0 ? 0 : newValue;
      }
      if (fatAmount != null) {
        final newValue = (updateDay.fatTracked ?? 0) - fatAmount;
        updateDay.fatTracked = newValue < 0 ? 0 : newValue;
      }
      if (proteinAmount != null) {
        final newValue = (updateDay.proteinTracked ?? 0) - proteinAmount;
        updateDay.proteinTracked = newValue < 0 ? 0 : newValue;
      }
      updateDay.save();
    }
  }
}
