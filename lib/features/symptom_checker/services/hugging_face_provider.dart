import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pet_pulse/features/symptom_checker/services/ai_provider.dart';
import 'package:pet_pulse/features/symptom_checker/screens/symptom_checker_screen.dart';

class HuggingFaceProvider implements AIProvider {
  final String apiKey;
  final String model;

  HuggingFaceProvider({
    required this.apiKey,
    this.model = 'meta-llama/Meta-Llama-3-8B-Instruct',
  });

  @override
  Future<SymptomAnalysisResult> analyze({
    required String prompt,
    String? imagePath,
  }) async {
    // Note: Standard HF Inference API for text-generation. 
    // For vision (image+text), we would need a model like 'llava-hf/llava-1.5-7b-hf' 
    // and potentially a different API structure depending on the model's pipeline.
    // This implementation assumes a text-based model or a compatible multimodal endpoint.
    
    final uri = Uri.parse('https://api-inference.huggingface.co/models/$model');
    
    // Constructing the input. For simple text models:
    String fullInput = prompt;
    if (imagePath != null) {
      // HF Inference API support for images varies by model. 
      // For simplicity in this "universal" provider, we might append a note 
      // or if using a specific vision model, send bytes.
      // Here we will append a note that image analysis is limited without a specific vision model.
      fullInput += "\n\n[Note: Image analysis via HF API requires a specific vision model configuration.]";
    }

    final requestBody = {
      "inputs": fullInput,
      "parameters": {
        "return_full_text": false,
        "max_new_tokens": 500,
      }
    };

    try {
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.isNotEmpty) {
          final generatedText = jsonResponse[0]['generated_text'];
          return _parseResponse(generatedText);
        } else {
           throw Exception("Empty response from Hugging Face");
        }
      } else {
        throw Exception("Hugging Face API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Failed to connect to Hugging Face: $e");
    }
  }

  SymptomAnalysisResult _parseResponse(String responseText) {
     // Attempt to parse JSON from the text. 
     // We rely on the prompt instructing the model to return JSON.
    try {
      final startIndex = responseText.indexOf('{');
      final endIndex = responseText.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) {
        final jsonStr = responseText.substring(startIndex, endIndex + 1);
        final data = jsonDecode(jsonStr);

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
      } else {
         throw FormatException("No JSON found in response");
      }
    } catch (e) {
      return SymptomAnalysisResult(
        severityScore: "Unknown",
        possibleConditions: [],
        actionRecommendation: "Raw Output: $responseText",
        shouldSeeVetNow: true,
      );
    }
  }
}
