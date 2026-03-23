import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:instant_post_poc/main.dart';
import 'package:instant_post_poc/core/config/app_environment.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppEnvironment(),
        child: const AIMagicApp(),
      ),
    );

    // Verify that the title text is found.
    expect(find.text('InstantPost AI'), findsOneWidget);
  });
}
