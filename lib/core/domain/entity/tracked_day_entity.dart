import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:opennutritracker/core/data/dbo/tracked_day_dbo.dart';
import 'package:opennutritracker/core/domain/entity/day_rating.dart';

class TrackedDayEntity extends Equatable {
  static const maxKcalDifferenceOverGoal = 500;
  static const maxKcalDifferenceUnderGoal = 1000;

  final DateTime day;
  final double calorieGoal;
  final double caloriesTracked;
  final double? carbsGoal;
  final double? carbsTracked;
  final double? fatGoal;
  final double? fatTracked;
  final double? proteinGoal;
  final double? proteinTracked;

  const TrackedDayEntity(
      {required this.day,
      required this.calorieGoal,
      required this.caloriesTracked,
      this.carbsGoal,
      this.carbsTracked,
      this.fatGoal,
      this.fatTracked,
      this.proteinGoal,
      this.proteinTracked});

  factory TrackedDayEntity.fromTrackedDayDBO(TrackedDayDBO trackedDayDBO) {
    return TrackedDayEntity(
        day: trackedDayDBO.day,
        calorieGoal: trackedDayDBO.calorieGoal,
        caloriesTracked: trackedDayDBO.caloriesTracked,
        carbsGoal: trackedDayDBO.carbsGoal,
        carbsTracked: trackedDayDBO.carbsTracked,
        fatGoal: trackedDayDBO.fatGoal,
        fatTracked: trackedDayDBO.fatTracked,
        proteinGoal: trackedDayDBO.proteinGoal,
        proteinTracked: trackedDayDBO.proteinTracked);
  }

  /// Returns the rating for this tracked day based on calorie goal adherence.
  DayRating get rating {
    if (_isWithinAcceptableCalorieDifference(calorieGoal, caloriesTracked)) {
      return DayRating.good;
    } else {
      return DayRating.poor;
    }
  }

  Color getCalendarDayRatingColor(BuildContext context) {
    return rating.getCalendarColor(context);
  }

  Color getRatingDayTextColor(BuildContext context) {
    return rating.getTextColor(context);
  }

  Color getRatingDayTextBackgroundColor(BuildContext context) {
    return rating.getTextBackgroundColor(context);
  }

  bool _isWithinAcceptableCalorieDifference(
      double calorieGoal, caloriesTracked) {
    double difference = calorieGoal - caloriesTracked;

    if (calorieGoal < caloriesTracked) {
      return difference.abs() < maxKcalDifferenceOverGoal;
    } else {
      return difference < maxKcalDifferenceUnderGoal;
    }
  }

  @override
  List<Object?> get props => [
        day,
        calorieGoal,
        caloriesTracked,
        carbsGoal,
        carbsTracked,
        fatGoal,
        fatTracked,
        proteinGoal,
        proteinTracked
      ];
}
