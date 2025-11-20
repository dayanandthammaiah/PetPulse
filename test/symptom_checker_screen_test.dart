import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_pulse/features/symptom_checker/screens/symptom_checker_screen.dart';
import 'package:pet_pulse/features/symptom_checker/services/ai_service.dart';

// Mock Service
class MockAIService extends AIService {
  @override
  Future<SymptomAnalysisResult> analyzeSymptoms({
    required String petType,
    required String breed,
    required String age,
    required String symptoms,
    String? imageUrl,
  }) async {
    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 100));
    return SymptomAnalysisResult(
      possibleConditions: [],
      severityScore: "Green",
      actionRecommendation: "Rest",
      shouldSeeVetNow: false,
    );
  }
}

void main() {
  testWidgets('SymptomCheckerScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SymptomCheckerScreen()));

    expect(find.text("AI Symptom Checker"), findsOneWidget);
    expect(find.text("Describe your pet's symptoms"), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Analyze button triggers loading state', (WidgetTester tester) async {
    // Inject Mock Service
    await tester.pumpWidget(MaterialApp(
      home: SymptomCheckerScreen(aiService: MockAIService()),
    ));

    await tester.enterText(find.byType(TextField), 'Coughing');
    await tester.tap(find.byType(ElevatedButton));
    
    // Rebuild to show loading state
    await tester.pump(); 

    // Verify Loading Indicator is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Verify Button text is GONE (replaced by loader)
    expect(find.text("Analyze Health Risk"), findsNothing);

    // Wait for future to complete
    await tester.pump(const Duration(milliseconds: 100));
    
    // Verify Result is shown (or at least loading is gone)
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text("Analyze Health Risk"), findsOneWidget); // Button comes back
  });
}
