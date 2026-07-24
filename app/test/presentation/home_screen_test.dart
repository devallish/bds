import 'package:bds_app/domain/entities/member_profile.dart';
import 'package:bds_app/domain/entities/member_role.dart';
import 'package:bds_app/domain/entities/person.dart';
import 'package:bds_app/domain/repositories/member_repository.dart';
import 'package:bds_app/presentation/providers/member_providers.dart';
import 'package:bds_app/presentation/screens/home_screen.dart';
import 'package:bds_app/presentation/screens/member_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_member_repository.dart';

MemberProfile _profile() => MemberProfile(
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
  addresses: const [],
);

Widget _app(MemberRepository repository) {
  return ProviderScope(
    overrides: [memberRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(
      home: HomeScreen(memberId: 'a0000000-0000-0000-0000-000000000004'),
    ),
  );
}

/// The feature list is taller than the default test surface. Growing the
/// surface avoids scrolling the list mid-test, which is flakier than just
/// making everything visible at once.
void _useTallTestSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('renders member summary and every feature area button', (
    tester,
  ) async {
    _useTallTestSurface(tester);
    await tester.pumpWidget(_app(FakeMemberRepository(_profile())));
    await tester.pumpAndSettle();

    expect(find.text('Mrs Test MemberSouthEastOne'), findsOneWidget);
    expect(find.textContaining('Region: South East'), findsOneWidget);

    // One button per functional area discussed so far.
    for (final label in [
      'My profile',
      'News & notifications',
      'Deer survey',
      'Observation report',
      'Stalking report',
      'Reporting & insights',
      'Training & qualifications',
      'Digital membership card',
      'Deer ID guide',
      'Health checks',
    ]) {
      expect(find.text(label), findsOneWidget, reason: 'missing "$label" button');
    }

    // Backlog ideas are visibly flagged as unscoped, not real features yet.
    expect(find.widgetWithText(Chip, 'Idea'), findsNWidgets(4));
  });

  testWidgets('tapping My profile opens MemberProfileScreen and back returns home', (
    tester,
  ) async {
    await tester.pumpWidget(_app(FakeMemberRepository(_profile())));
    await tester.pumpAndSettle();

    await tester.tap(find.text('My profile'));
    await tester.pumpAndSettle();

    expect(find.byType(MemberProfileScreen), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('My profile'), findsOneWidget);
  });

  testWidgets('tapping a not-yet-built feature opens a placeholder and back returns home', (
    tester,
  ) async {
    await tester.pumpWidget(_app(FakeMemberRepository(_profile())));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Deer survey'));
    await tester.pumpAndSettle();

    expect(find.text('Coming soon'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Deer survey'), findsOneWidget);
  });

  testWidgets('flags backlog idea placeholders as unscoped', (tester) async {
    _useTallTestSurface(tester);
    await tester.pumpWidget(_app(FakeMemberRepository(_profile())));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Deer ID guide'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('unscoped idea, not yet committed for build'),
      findsOneWidget,
    );
  });
}
