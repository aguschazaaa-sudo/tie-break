import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_punilla/presentation/widgets/shimmer_overlay.dart';
import 'package:padel_punilla/presentation/widgets/surface_card.dart';

void main() {
  group('SurfaceCard', () {
    testWidgets('renders child correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SurfaceCard(child: Text('Test Child'))),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('executes onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SurfaceCard(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me')); // Tap the text/content
      expect(tapped, isTrue);
    });

    testWidgets('renders glass effect when isGlass is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SurfaceCard(isGlass: true, child: Text('Glass')),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('renders shimmer effect when isShiny is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SurfaceCard(isShiny: true, child: Text('Shiny')),
          ),
        ),
      );

      expect(find.byType(ShimmerOverlay), findsOneWidget);
    });
  });
}
