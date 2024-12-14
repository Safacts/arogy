import 'package:flutter_test/flutter_test.dart';

import 'package:arogy/main.dart';

void main() {
  testWidgets('ArogyApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ArogyApp());

    // Verify that the app title is displayed.
    expect(find.text('Arogy Patient Diagnosis'), findsOneWidget);

    // Verify that the form fields are present.
    expect(find.text('Age'), findsOneWidget);
    expect(find.text('Cholesterol'), findsOneWidget);
    expect(find.text('Resting Blood Pressure'), findsOneWidget);

    // Verify that the submit button is present.
    expect(find.text('Submit'), findsOneWidget);
  });
}
