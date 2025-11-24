import 'package:flutter_test/flutter_test.dart';
import 'package:pet_pulse/features/symptom_checker/services/ai_service.dart';
import 'package:pet_pulse/features/symptom_checker/services/ai_provider.dart';
import 'package:pet_pulse/features/symptom_checker/screens/symptom_checker_screen.dart';

class MockAIProvider implements AIProvider {
  @override
  Future<SymptomAnalysisResult> analyze({required String prompt, String? imagePath}) async {
    return SymptomAnalysisResult(
      possibleConditions: [PossibleCondition(name: "Test Condition", probability: 0.9)],
      severityScore: "Green",
      actionRecommendation: "Test Recommendation",
      shouldSeeVetNow: false,
    );
  }
}

void main() {
  group('AIService Tests', () {
    late AIService aiService;

    setUp(() {
      aiService = AIService(provider: MockAIProvider());
    });

    test('analyzeSymptoms returns valid result', () async {
      final result = await aiService.analyzeSymptoms(
        petType: 'Dog',
        breed: 'Labrador',
        age: '5',
        symptomDescription: 'Limping on back leg',
      );

      expect(result, isA<SymptomAnalysisResult>());
      expect(result.possibleConditions, isNotEmpty);
      expect(result.severityScore, equals("Green"));
    });
  });
}
