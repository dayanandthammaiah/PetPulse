import 'package:pet_pulse/features/symptom_checker/screens/symptom_checker_screen.dart'; // For SymptomAnalysisResult

abstract class AIProvider {
  Future<SymptomAnalysisResult> analyze({
    required String prompt,
    String? imagePath,
  });
}
