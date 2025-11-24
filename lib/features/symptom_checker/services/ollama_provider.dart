import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pet_pulse/features/symptom_checker/services/ai_provider.dart';
import 'package:pet_pulse/features/symptom_checker/screens/symptom_checker_screen.dart';

class OllamaProvider implements AIProvider {
  final String baseUrl;
  final String model;

  OllamaProvider({
    this.baseUrl = 'http://10.0.2.2:11434', // Default for Android Emulator -> Localhost
    this.model = 'llava', // Default vision model
  });

  @override
  Future<SymptomAnalysisResult> analyze({
    required String prompt,
    String? imagePath,
  }) async {
    final uri = Uri.parse('$baseUrl/api/generate');
    
    List<String> images = [];
    if (imagePath != null) {
      final bytes = await File(imagePath).readAsBytes();
      images.add(base64Encode(bytes));
    }

    final requestBody = {
      "model": model,
      "prompt": "$prompt\n\nRespond in JSON format with the following structure: { \"severityScore\": \"Red/Green\", \"possibleConditions\": [{\"name\": \"Condition Name\", \"probability\": 0.9}], \"actionRecommendation\": \"Recommendation text\", \"shouldSeeVetNow\": true/false }",
      "stream": false,
      "format": "json", // Force JSON mode if supported by model
      if (images.isNotEmpty) "images": images,
    };

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final responseText = jsonResponse['response'];
        return _parseResponse(responseText);
      } else {
        throw Exception("Ollama API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Failed to connect to Ollama: $e");
    }
  }

  SymptomAnalysisResult _parseResponse(String responseText) {
    try {
      // Clean up markdown code blocks if present
      final cleanJson = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      final data = jsonDecode(cleanJson);

      return SymptomAnalysisResult(
        severityScore: data['severityScore'] ?? "Unknown",
        possibleConditions: (data['possibleConditions'] as List?)
                ?.map((e) => PossibleCondition(
                      name: e['name'] ?? "Unknown",
                      probability: (e['probability'] as num?)?.toDouble() ?? 0.0,
                    ))
                .toList() ??
            [],
        actionRecommendation: data['actionRecommendation'] ?? "Consult a vet.",
        shouldSeeVetNow: data['shouldSeeVetNow'] ?? false,
      );
    } catch (e) {
      // Fallback if JSON parsing fails
      return SymptomAnalysisResult(
        severityScore: "Unknown",
        possibleConditions: [],
        actionRecommendation: "Could not parse AI response. Raw output: $responseText",
        shouldSeeVetNow: true,
      );
    }
  }
}
