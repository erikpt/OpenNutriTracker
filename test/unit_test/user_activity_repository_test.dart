import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:opennutritracker/core/data/data_source/user_activity_data_source.dart';
import 'package:opennutritracker/core/data/data_source/user_activity_dbo.dart';
import 'package:opennutritracker/core/data/dbo/physical_activity_dbo.dart';
import 'package:opennutritracker/core/data/repository/user_activity_repository.dart';

void main() {
  group('UserActivityRepository', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      Hive.registerAdapter(UserActivityDBOAdapter());
      Hive.registerAdapter(PhysicalActivityDBOAdapter());
      Hive.registerAdapter(PhysicalActivityTypeDBOAdapter());
    });

    setUp(() {
      Hive.init('.');
    });

    tearDown(() async {
      await Hive.close();
      Hive.deleteFromDisk();
    });

    test('updateUserActivity updates duration and recalculates burnedKcal',
        () async {
      final box = await Hive.openBox<UserActivityDBO>('activity_test');
      final repo = UserActivityRepository(UserActivityDataSource(box));

      final physicalActivity = PhysicalActivityDBO(
        'running_general',
        'running, general',
        'running, general',
        8.0, // MET value
        [],
        PhysicalActivityTypeDBO.running,
      );

      final activity = UserActivityDBO(
        'test-id-1',
        30.0, // 30 minutes
        50.0, // original burnedKcal (placeholder)
        DateTime.utc(2024, 6, 1),
        physicalActivity,
      );
      await box.add(activity);

      final updated = await repo.updateUserActivity('test-id-1', 60.0, 99.5);

      expect(updated, isNotNull);
      expect(updated!.id, equals('test-id-1'));
      expect(updated.duration, equals(60.0));
      expect(updated.burnedKcal, equals(99.5));
      expect(updated.physicalActivityEntity.code, equals('running_general'));
    });

    test('updateUserActivity returns null for unknown id', () async {
      final box = await Hive.openBox<UserActivityDBO>('activity_test');
      final repo = UserActivityRepository(UserActivityDataSource(box));

      final result =
          await repo.updateUserActivity('nonexistent', 60.0, 100.0);
      expect(result, isNull);
    });
  });
}
