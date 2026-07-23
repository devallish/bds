import 'package:bds_app/domain/entities/address.dart';
import 'package:bds_app/domain/entities/member_profile.dart';
import 'package:bds_app/domain/entities/member_role.dart';
import 'package:bds_app/domain/entities/person.dart';
import 'package:bds_app/domain/repositories/member_repository.dart';
import 'package:bds_app/presentation/providers/member_providers.dart';
import 'package:bds_app/presentation/screens/member_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_member_repository.dart';

void main() {
  testWidgets(
    'renders member, person, and address data from the repository',
    (tester) async {
      final profile = MemberProfile(
        memberId: 'a0000000-0000-0000-0000-000000000004',
        region: 'South East',
        role: MemberRole.member,
        membershipNumber: 'BDS-0004',
        joinedAt: DateTime(2023, 2, 20),
        person: const Person(
          title: 'Mrs',
          firstNames: 'Test',
          lastName: 'MemberSouthEastOne',
        ),
        addresses: const [
          Address(
            addressType: 'Home',
            line1: '4 Test Street',
            town: 'Southtown',
            county: 'Kent',
            postcode: 'TE4 4ST',
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            memberRepositoryProvider.overrideWithValue(
              FakeMemberRepository(profile),
            ),
          ],
          child: const MaterialApp(
            home: MemberProfileScreen(
              memberId: 'a0000000-0000-0000-0000-000000000004',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mrs Test MemberSouthEastOne'), findsOneWidget);
      expect(find.text('Region: South East'), findsOneWidget);
      expect(find.text('Membership number: BDS-0004'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(
        find.text('4 Test Street, Southtown, Kent, TE4 4ST'),
        findsOneWidget,
      );
    },
  );

  testWidgets('shows an error message when the repository fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memberRepositoryProvider.overrideWithValue(_FailingRepository()),
        ],
        child: const MaterialApp(
          home: MemberProfileScreen(memberId: 'does-not-matter'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Could not load member profile'), findsOneWidget);
  });
}

class _FailingRepository implements MemberRepository {
  @override
  Future<MemberProfile> getMemberProfile(String memberId) {
    throw Exception('network error');
  }
}
