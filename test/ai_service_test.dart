import 'package:flutter_test/flutter_test.dart';
import 'package:pet_pulse/features/symptom_checker/services/ai_service.dart';

void main() {
  group('AIService Tests', () {
    late AIService aiService;

    setUp(() {
      aiService = AIService();
    });

    test('analyzeSymptoms returns valid result', () async {
      final result = await aiService.analyzeSymptoms(
        petType: 'Dog',
        breed: 'Labrador',
        age: '5',
        symptoms: 'Limping on back leg',
      );

      expect(result, isA<SymptomAnalysisResult>());
      expect(result.possibleConditions, isNotEmpty);
      expect(result.severityScore, isNotEmpty);
    });

    test('analyzeSymptoms handles empty symptoms gracefully', () async {
      // Depending on implementation, this might throw or return a default
      // For now, we assume it returns a result but with low confidence or specific message
      // Or we can expect it to throw if validation is added
    });
  });
}
