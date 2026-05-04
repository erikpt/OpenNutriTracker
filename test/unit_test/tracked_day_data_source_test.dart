import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:opennutritracker/core/data/data_source/tracked_day_data_source.dart';
import 'package:opennutritracker/core/data/dbo/tracked_day_dbo.dart';

void main() {
  group('TrackedDayDataSource getTrackedDaysInRange test', () {
    late Box<TrackedDayDBO> box;
    late TrackedDayDataSource dataSource;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      Hive.registerAdapter(TrackedDayDBOAdapter());
    });

    setUp(() async {
      Hive.init('.');
      box = await Hive.openBox<TrackedDayDBO>('tracked_day_test');
      dataSource = TrackedDayDataSource(box);
    });

    tearDown(() async {
      await box.clear();
      await Hive.close();
      await Hive.deleteFromDisk();
    });

    test('returns tracked days within range inclusively', () async {
      final day1 = DateTime.utc(2024, 1, 1);
      final day2 = DateTime.utc(2024, 1, 2);
      final day3 = DateTime.utc(2024, 1, 3);
      final day4 = DateTime.utc(2024, 1, 4);
      final day5 = DateTime.utc(2024, 1, 5);

      await dataSource.saveTrackedDay(TrackedDayDBO(
        day: day1,
        calorieGoal: 2000,
        caloriesTracked: 1500,
        carbsGoal: 250,
        carbsTracked: 200,
        fatGoal: 65,
        fatTracked: 50,
        proteinGoal: 150,
        proteinTracked: 120,
      ));

      await dataSource.saveTrackedDay(TrackedDayDBO(
        day: day2,
        calorieGoal: 2000,
        caloriesTracked: 1800,
        carbsGoal: 250,
        carbsTracked: 220,
        fatGoal: 65,
        fatTracked: 60,
        proteinGoal: 150,
        proteinTracked: 140,
      ));

      await dataSource.saveTrackedDay(TrackedDayDBO(
        day: day3,
        calorieGoal: 2000,
        caloriesTracked: 2100,
        carbsGoal: 250,
        carbsTracked: 260,
        fatGoal: 65,
        fatTracked: 70,
        proteinGoal: 150,
        proteinTracked: 160,
      ));

      await dataSource.saveTrackedDay(TrackedDayDBO(
        day: day4,
        calorieGoal: 2000,
        caloriesTracked: 1900,
        carbsGoal: 250,
        carbsTracked: 240,
        fatGoal: 65,
        fatTracked: 62,
        proteinGoal: 150,
        proteinTracked: 145,
      ));

      await dataSource.saveTrackedDay(TrackedDayDBO(
        day: day5,
        calorieGoal: 2000,
        caloriesTracked: 1600,
        carbsGoal: 250,
        carbsTracked: 190,
        fatGoal: 65,
        fatTracked: 55,
        proteinGoal: 150,
        proteinTracked: 130,
      ));

      final result = await dataSource.getTrackedDaysInRange(day2, day4);

      expect(result.length, 3);
      expect(result.map((e) => e.day).toList(), containsAll([day2, day3, day4]));

      final resultDays = result.map((e) => e.day).toList();
      expect(resultDays.contains(day1), false);
      expect(resultDays.contains(day5), false);
    });

    test('includes boundary days in range query', () async {
      final startDay = DateTime.utc(2024, 1, 1);
      final endDay = DateTime.utc(2024, 1, 3);

      await dataSource.saveTrackedDay(TrackedDayDBO(
        day: startDay,
        calorieGoal: 2000,
        caloriesTracked: 1500,
      ));

      await dataSource.saveTrackedDay(TrackedDayDBO(
        day: endDay,
        calorieGoal: 2000,
        caloriesTracked: 1800,
      ));

      final result = await dataSource.getTrackedDaysInRange(startDay, endDay);

      expect(result.length, 2);
      expect(result.map((e) => e.day).toList(), containsAll([startDay, endDay]));
    });

    test('returns empty list when no days in range', () async {
      final day1 = DateTime.utc(2024, 1, 1);

      await dataSource.saveTrackedDay(TrackedDayDBO(
        day: day1,
        calorieGoal: 2000,
        caloriesTracked: 1500,
      ));

      final result = await dataSource.getTrackedDaysInRange(
        DateTime.utc(2024, 1, 20),
        DateTime.utc(2024, 1, 25),
      );

      expect(result.length, 0);
    });
  });
}
