import 'package:bds_app/domain/entities/member_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemberRole.fromDbValue', () {
    test('maps each known database value to its enum case', () {
      expect(MemberRole.fromDbValue('member'), MemberRole.member);
      expect(
        MemberRole.fromDbValue('regional_coordinator'),
        MemberRole.regionalCoordinator,
      );
      expect(
        MemberRole.fromDbValue('national_admin'),
        MemberRole.nationalAdmin,
      );
    });

    test('throws on an unrecognised value', () {
      expect(() => MemberRole.fromDbValue('superadmin'), throwsArgumentError);
    });
  });
}
