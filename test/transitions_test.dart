import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawakarsa/core/app_transitions.dart';

void main() {
  testWidgets('DirectionalTabSwitcher switches tabs smoothly', (tester) async {
    int index = 0;
    bool isForward = true;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: DirectionalTabSwitcher(
                currentIndex: index,
                isForward: isForward,
                child: Text('Tab $index'),
              ),
              floatingActionButton: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() {
                      isForward = true;
                      index = 1;
                    }),
                    child: const Text('Next'),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      isForward = false;
                      index = 0;
                    }),
                    child: const Text('Prev'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Tab 0'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Tab 1'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Tab 1'), findsOneWidget);
    expect(find.text('Tab 0'), findsNothing);

    await tester.tap(find.text('Prev'));
    await tester.pumpAndSettle();
    expect(find.text('Tab 0'), findsOneWidget);
    expect(find.text('Tab 1'), findsNothing);
  });

  testWidgets('DirectionalTabSwitcher respects reduced motion', (tester) async {
    int index = 0;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: DirectionalTabSwitcher(
                  currentIndex: index,
                  isForward: true,
                  child: Text('Tab $index'),
                ),
                floatingActionButton: ElevatedButton(
                  onPressed: () => setState(() => index = 2),
                  child: const Text('Jump'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Jump'));
    await tester.pump();
    expect(find.text('Tab 2'), findsOneWidget);
    expect(find.text('Tab 0'), findsNothing);
  });

  testWidgets('AppTransitions push and replace routes navigate cleanly', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          pageTransitionsTheme: AppTransitions.pageTransitionsTheme,
        ),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      AppTransitions.fadeSlideRoute(
                        page: const Scaffold(body: Text('Slide Destination')),
                      ),
                    ),
                    child: const Text('Push Slide'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      AppTransitions.fadeScaleRoute(
                        page: const Scaffold(body: Text('Scale Destination')),
                      ),
                    ),
                    child: const Text('Push Scale'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Push Slide'));
    await tester.pumpAndSettle();
    expect(find.text('Slide Destination'), findsOneWidget);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.text('Push Slide'), findsOneWidget);

    await tester.tap(find.text('Push Scale'));
    await tester.pumpAndSettle();
    expect(find.text('Scale Destination'), findsOneWidget);
  });

  testWidgets('KeepAliveTabSwitcher lazily builds and preserves state', (
    tester,
  ) async {
    int index = 0;
    final builtTabs = <int>{};

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: KeepAliveTabSwitcher(
                currentIndex: index,
                itemCount: 3,
                itemBuilder: (context, i) {
                  builtTabs.add(i);
                  return Text('Cached Tab $i');
                },
              ),
              floatingActionButton: ElevatedButton(
                onPressed: () => setState(() => index = (index + 1) % 3),
                child: const Text('Switch'),
              ),
            );
          },
        ),
      ),
    );

    expect(builtTabs, {0});
    expect(find.text('Cached Tab 0'), findsOneWidget);

    await tester.tap(find.text('Switch'));
    await tester.pumpAndSettle();
    expect(builtTabs, {0, 1});
    expect(find.text('Cached Tab 1'), findsOneWidget);
    expect(find.text('Cached Tab 0', skipOffstage: true), findsNothing);
    expect(find.text('Cached Tab 0', skipOffstage: false), findsOneWidget);
  });
}
