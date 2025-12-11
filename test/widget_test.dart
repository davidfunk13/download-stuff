// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:download_stuff/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:download_stuff/features/counter/presentation/riverpod/backend_provider.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          backendHealthProvider.overrideWith(
            (ref) => Stream.value('Mocked W.E.N.I.S.'),
          ),
          randomMessageProvider.overrideWith(
            (ref) => Stream.value('Mocked Random Message'),
          ),
        ],
        child: const App(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('PoC Interaction Test', (WidgetTester tester) async {
    // Variable to simulate changing backend state
    int callCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          backendHealthProvider.overrideWith(
            (ref) => Stream.value('Mocked W.E.N.I.S.'),
          ),
          randomMessageProvider.overrideWith((ref) {
            callCount++;
            return Stream.value('Random Message $callCount');
          }),
        ],
        child: const App(),
      ),
    );

    // Initial State Check
    // We expect "Random Message 1" because the provider is watched immediately in build()
    await tester.pumpAndSettle();
    expect(find.text('Random Message 1'), findsOneWidget);

    // Act: Tap the refresh button
    // Find button by text "Fetch Random Message" which is inside the ElevatedButton label
    await tester.tap(find.text('Fetch Random Message'));

    // Allow Future to complete and UI to rebuild
    // pumpAndSettle waits for animations and scheduled frames
    await tester.pumpAndSettle();

    // Assert: Check if text updated to "Random Message 2"
    expect(find.text('Random Message 2'), findsOneWidget);
  });
}
