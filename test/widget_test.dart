import 'package:flutter_test/flutter_test.dart';
import 'package:plant_care/main.dart';

void main() {
  testWidgets('Home screen loads correctly', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const PlantCareApp());

    // Check if the title exists
    expect(find.text('Plant Care Log'), findsOneWidget);

    // Check if the tagline exists
    expect(find.text('Track and manage your plants easily'), findsOneWidget);

    // Check if the "Get Started" button exists
    expect(find.text('Get Started'), findsOneWidget);

    // Test tapping the button
    await tester.tap(find.text('Get Started'));
    await tester.pump();
  });
}
