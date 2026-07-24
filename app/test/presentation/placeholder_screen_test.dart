import 'package:bds_app/presentation/screens/placeholder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders title, description, and coming-soon state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlaceholderScreen(
          title: 'Deer survey',
          description: 'Submit a deer survey for your region.',
        ),
      ),
    );

    expect(find.text('Deer survey'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);
    expect(find.text('Submit a deer survey for your region.'), findsOneWidget);
    expect(find.textContaining('unscoped idea'), findsNothing);
  });

  testWidgets('flags backlog ideas as unscoped', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlaceholderScreen(
          title: 'Deer ID guide',
          description: 'An in-app guide to identifying deer species.',
          isBacklogIdea: true,
        ),
      ),
    );

    expect(
      find.textContaining('unscoped idea, not yet committed for build'),
      findsOneWidget,
    );
  });
}
