import 'package:pet_pulse/features/symptom_checker/services/ai_provider.dart';
import 'package:pet_pulse/features/symptom_checker/services/ollama_provider.dart';
import 'package:pet_pulse/features/symptom_checker/screens/symptom_checker_screen.dart'; // For SymptomAnalysisResult

class AIService {
  AIProvider _provider;

  AIService({AIProvider? provider}) : _provider = provider ?? OllamaProvider();

  void setProvider(AIProvider provider) {
    _provider = provider;
  }

  Future<SymptomAnalysisResult> analyzeSymptoms({
    required String petType,
    required String breed,
    required String age,
    required String symptomDescription,
    String? imagePath,
  }) async {
    final prompt = """
Act as a veterinary AI assistant. Analyze the following pet health issue:
Pet: $petType, Breed: $breed, Age: $age
Symptoms: $symptomDescription

Provide a risk assessment in JSON format with:
- severityScore: "Red" (Critical) or "Green" (Non-critical)
- possibleConditions: List of objects {name, probability}
- actionRecommendation: Clear advice on what to do
- shouldSeeVetNow: boolean
""";

    return _provider.analyze(prompt: prompt, imagePath: imagePath);
  }
}
