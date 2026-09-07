import 'package:flutter_test/flutter_test.dart';
import 'package:zest/features/events/models/event_model.dart';
import 'package:zest/core/services/auth_service.dart';

void main() {
  group('Auth and Tournament Authority Tests', () {
    const testSuperAdminEmail = 'mehtaajay8873@gmail.com';

    setUp(() {
      AuthService.registerSuperAdminForTesting(testSuperAdminEmail);
    });

    tearDown(() {
      AuthService.clearSuperAdminsForTesting();
    });

    final testEvent = EventModel(
      id: 'fest-001',
      name: 'Plexus 2026 Sports Meet',
      startDate: DateTime(2026, 3, 10),
      endDate: DateTime(2026, 3, 14),
      shareSlug: 'plexus-2026',
      description: 'Annual inter-college athletic tournament',
      adminPin: '4321',
      creatorEmail: 'creator@sportsfest.edu',
      adminEmails: ['coadmin1@college.edu', 'coadmin2@college.edu'],
    );

    test('Superadmin verified from Supabase SQL has global tournament admin authority', () {
      expect(AuthService.isSuperAdminEmail(testSuperAdminEmail), isTrue);
      expect(testEvent.canUserAdmin(testSuperAdminEmail), isTrue);
      expect(testEvent.canUserAdmin('MEHTAAJAY8873@GMAIL.COM '), isTrue);
    });

    test('Tournament creator has primary admin authority', () {
      expect(testEvent.canUserAdmin('creator@sportsfest.edu'), isTrue);
      expect(testEvent.canUserAdmin(' CREATOR@sportsfest.edu'), isTrue);
    });

    test('Authorized co-admins have admin authority', () {
      expect(testEvent.canUserAdmin('coadmin1@college.edu'), isTrue);
      expect(testEvent.canUserAdmin('coadmin2@college.edu'), isTrue);
    });

    test('Spectators and unlisted emails have view-only access', () {
      expect(testEvent.canUserAdmin('spectator@gmail.com'), isFalse);
      expect(testEvent.canUserAdmin('random@college.edu'), isFalse);
      expect(testEvent.canUserAdmin(null), isFalse);
      expect(testEvent.canUserAdmin(''), isFalse);
    });

    test('EventModel serializes and deserializes creator and admin tags cleanly', () {
      final json = testEvent.toJson();
      expect(json['description'], contains('[creator:creator@sportsfest.edu]'));
      expect(json['description'], contains('[admins:coadmin1@college.edu,coadmin2@college.edu]'));
      expect(json['description'], contains('[pin:4321]'));

      final reconstructed = EventModel.fromJson(json);
      expect(reconstructed.creatorEmail, equals('creator@sportsfest.edu'));
      expect(reconstructed.adminEmails, contains('coadmin1@college.edu'));
      expect(reconstructed.adminEmails, contains('coadmin2@college.edu'));
      expect(reconstructed.adminPin, equals('4321'));
      expect(reconstructed.canUserAdmin('creator@sportsfest.edu'), isTrue);
      expect(reconstructed.canUserAdmin('coadmin1@college.edu'), isTrue);
      expect(reconstructed.canUserAdmin(testSuperAdminEmail), isTrue);
      expect(reconstructed.canUserAdmin('intruder@random.com'), isFalse);
    });

    test('Other people and fresh installs do not prefill any email', () async {
      final email = await AuthService.getAutofetchedEmail();
      expect(email, isEmpty);
    });
  });
}
