import 'package:flutter_test/flutter_test.dart';
import 'package:pet_pulse/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PetPulseApp());

    // Verify that the home screen text is present.
    expect(find.text('Home - Breed Feed (Coming Soon)'), findsOneWidget);
  });
}
