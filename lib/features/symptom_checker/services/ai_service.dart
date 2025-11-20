import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // In a real app, store this securely (e.g., Firebase Remote Config or .env)
  // Use --dart-define=GEMINI_API_KEY=your_key at build time
  final String _apiKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'YOUR_API_KEY_HERE'); 
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  Future<SymptomAnalysisResult> analyzeSymptoms({
    required String petType,
    required String breed,
    required String age,
    required String symptoms,
    String? imageUrl, // Optional: Pass image URL if using multimodal model
  }) async {
    
    final prompt = _constructPrompt(petType, breed, age, symptoms);

    try {
      // Mocking the response for now to ensure the app runs without a valid key immediately
      // In production, uncomment the API call below
      
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{
            "parts": [{"text": prompt}]
          }]
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return _parseAIResponse(text);
      } else {
        throw Exception('Failed to analyze symptoms');
      }
      */

      // SIMULATED DELAY & RESPONSE
      await Future.delayed(const Duration(seconds: 2));
      return SymptomAnalysisResult(
        possibleConditions: [
          Condition(name: "Conjunctivitis", probability: 0.85, description: "Inflammation of the eye membrane."),
          Condition(name: "Corneal Ulcer", probability: 0.15, description: "Scratch or abrasion on the eye surface."),
        ],
        severityScore: "Yellow",
        actionRecommendation: "Clean the eye with saline solution. If squinting persists for >24h, see a vet.",
        shouldSeeVetNow: false,
      );

    } catch (e) {
      throw Exception('AI Analysis failed: $e');
    }
  }

  String _constructPrompt(String petType, String breed, String age, String symptoms) {
    return """
    Act as an expert veterinarian. Analyze the following pet health issue:
    
    Patient: $petType, Breed: $breed, Age: $age
    Symptoms: $symptoms
    
    Provide a structured JSON response with:
    1. List of top 3 possible conditions with probability (0-1).
    2. Severity score (Green/Yellow/Red).
    3. Immediate action recommendations (home care vs vet).
    4. Boolean 'see_vet_now' trigger.
    
    Format:
    {
      "conditions": [{"name": "...", "prob": 0.0, "desc": "..."}],
      "severity": "...",
      "recommendation": "...",
      "see_vet_now": false
    }
    """;
  }

  SymptomAnalysisResult _parseAIResponse(String jsonString) {
    // Implement JSON parsing logic here to convert the LLM response into the model
    // This is a placeholder implementation
    final Map<String, dynamic> data = jsonDecode(jsonString);
    // ... parsing logic
    return SymptomAnalysisResult(
        possibleConditions: [], 
        severityScore: "Unknown", 
        actionRecommendation: "Consult a vet.", 
        shouldSeeVetNow: true
    );
  }
}

class SymptomAnalysisResult {
  final List<Condition> possibleConditions;
  final String severityScore;
  final String actionRecommendation;
  final bool shouldSeeVetNow;

  SymptomAnalysisResult({
    required this.possibleConditions,
    required this.severityScore,
    required this.actionRecommendation,
    required this.shouldSeeVetNow,
  });
}

class Condition {
  final String name;
  final double probability;
  final String description;

  Condition({required this.name, required this.probability, required this.description});
}
