import 'package:flutter_test/flutter_test.dart';
import 'package:mysimpanan/services/notification_service.dart';

class MockNotificationService extends NotificationService {
  final List<String> scheduledReminders = [];
  final List<String> cancelledReminders = [];
  bool isInitialized = false;

  @override
  Future<bool> initialize() async {
    isInitialized = true;
    return true;
  }

  @override
  Future<bool> scheduleInstallmentReminder({
    required String reminderId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    scheduledReminders.add('$reminderId:$title:$scheduledDate');
    return true;
  }

  @override
  Future<bool> cancelReminder(String reminderId) async {
    cancelledReminders.add(reminderId);
    return true;
  }
}

void main() {
  group('NotificationService alert date calculation', () {
    test('calculateAlertDate subtracts lead days and sets designated alert hour', () {
      final dueDate = DateTime(2026, 11, 20, 15, 30);
      final alertDate = NotificationService.calculateAlertDate(
        dueDate: dueDate,
        leadDays: 3,
        alertHour: 9,
      );

      expect(alertDate, isNotNull);
      expect(alertDate!.year, equals(2026));
      expect(alertDate.month, equals(11));
      expect(alertDate.day, equals(17));
      expect(alertDate.hour, equals(9));
      expect(alertDate.minute, equals(0));
      expect(alertDate.second, equals(0));
    });

    test('calculateAlertDate handles leadDays = 0 (same day alert)', () {
      final dueDate = DateTime(2026, 12, 1, 12, 0);
      final alertDate = NotificationService.calculateAlertDate(
        dueDate: dueDate,
        leadDays: 0,
        alertHour: 8,
      );

      expect(alertDate, isNotNull);
      expect(alertDate!.year, equals(2026));
      expect(alertDate.month, equals(12));
      expect(alertDate.day, equals(1));
      expect(alertDate.hour, equals(8));
    });

    test('calculateAlertDate returns null or current when alert date is in past relative to reference time', () {
      final dueDate = DateTime(2026, 5, 10, 9, 0);
      final now = DateTime(2026, 5, 8, 12, 0);

      final alertDate = NotificationService.calculateAlertDate(
        dueDate: dueDate,
        leadDays: 5,
        alertHour: 9,
        referenceNow: now,
      );

      // 5 days before May 10 is May 5 09:00, which is earlier than May 8
      expect(alertDate, isNull);
    });

    test('calculateAlertDate succeeds when alert date is in future relative to reference time', () {
      final dueDate = DateTime(2026, 5, 10, 9, 0);
      final now = DateTime(2026, 5, 2, 12, 0);

      final alertDate = NotificationService.calculateAlertDate(
        dueDate: dueDate,
        leadDays: 5,
        alertHour: 9,
        referenceNow: now,
      );

      expect(alertDate, isNotNull);
      expect(alertDate!.day, equals(5));
      expect(alertDate.isAfter(now), isTrue);
    });
  });

  group('Mockable NotificationService interface', () {
    test('initializes and manages reminders without device dependencies', () async {
      final service = MockNotificationService();
      final initialized = await service.initialize();
      expect(initialized, isTrue);
      expect(service.isInitialized, isTrue);

      final targetDate = DateTime(2026, 11, 25, 9, 0);
      await service.scheduleInstallmentReminder(
        reminderId: 'rem-1',
        title: 'Installment Reminder',
        body: 'ASNB installment due in 3 days',
        scheduledDate: targetDate,
      );
      expect(service.scheduledReminders.length, equals(1));
      expect(service.scheduledReminders.first, contains('rem-1'));

      await service.cancelReminder('rem-1');
      expect(service.cancelledReminders.length, equals(1));
      expect(service.cancelledReminders.first, equals('rem-1'));
    });
  });
}
