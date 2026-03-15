import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/dbo/water_intake_dbo.dart';

class WaterDataSource {
  final log = Logger('WaterDataSource');
  final Box<WaterIntakeDBO> _waterIntakeBox;

  WaterDataSource(this._waterIntakeBox);

  Future<void> addWaterIntake(WaterIntakeDBO dbo) async {
    log.fine('Adding water intake to db');
    await _waterIntakeBox.add(dbo);
  }

  Future<List<WaterIntakeDBO>> getTodayWaterIntakes(DateTime dateTime) async {
    return _waterIntakeBox.values
        .where((dbo) => DateUtils.isSameDay(dbo.dateTime, dateTime))
        .toList();
  }

  Future<void> deleteWaterIntake(String id) async {
    log.fine('Deleting water intake $id from db');
    _waterIntakeBox.values
        .where((dbo) => dbo.id == id)
        .toList()
        .forEach((element) {
      element.delete();
    });
  }
}
