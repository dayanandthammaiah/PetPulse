import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_pulse/features/symptom_checker/logic/symptom_checker_bloc.dart';
import 'package:pet_pulse/features/symptom_checker/services/ai_service.dart';
import 'package:pet_pulse/features/symptom_checker/services/ollama_provider.dart';
import 'package:pet_pulse/features/symptom_checker/services/hugging_face_provider.dart';

// Moved models here for simplicity, ideally in a separate model file
class SymptomAnalysisResult {
  final List<PossibleCondition> possibleConditions;
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

class PossibleCondition {
  final String name;
  final double probability;

  PossibleCondition({required this.name, required this.probability});
}

class SymptomCheckerScreen extends StatelessWidget {
  final AIService? aiService;
  
  const SymptomCheckerScreen({super.key, this.aiService});

  @override
  Widget build(BuildContext context) {
    // We need to keep the service instance alive to persist provider settings
    // In a real app, use a DI container like GetIt
    final service = aiService ?? AIService();

    return BlocProvider(
      create: (context) => SymptomCheckerBloc(service),
      child: _SymptomCheckerView(aiService: service),
    );
  }
}

class _SymptomCheckerView extends StatefulWidget {
  final AIService aiService;
  const _SymptomCheckerView({required this.aiService});

  @override
  State<_SymptomCheckerView> createState() => _SymptomCheckerViewState();
}

class _SymptomCheckerViewState extends State<_SymptomCheckerView> {
  final TextEditingController _symptomController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => _ProviderSettingsDialog(aiService: widget.aiService),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Symptom Checker"),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Describe your pet's symptoms",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _symptomController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "e.g., My dog has red eyes and is scratching them...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Image Picker UI
              if (_selectedImage != null)
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_selectedImage!, height: 200, width: double.infinity, fit: BoxFit.cover),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(backgroundColor: Colors.black54),
                      onPressed: () => setState(() => _selectedImage = null),
                    ),
                  ],
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text("Add Photo (Optional)"),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                ),
                
              const SizedBox(height: 24),
              BlocConsumer<SymptomCheckerBloc, SymptomCheckerState>(
                listener: (context, state) {
                  if (state is SymptomCheckerFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${state.error}")),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is SymptomCheckerLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: () {
                      if (_symptomController.text.isNotEmpty) {
                        context.read<SymptomCheckerBloc>().add(AnalyzeSymptoms(
                              petType: "Dog",
                              breed: "Golden Retriever",
                              age: "3 years",
                              symptomDescription: _symptomController.text,
                              imagePath: _selectedImage?.path,
                            ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please describe the symptoms.")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Analyze Health Risk"),
                  );
                },
              ),
              const SizedBox(height: 24),
              BlocBuilder<SymptomCheckerBloc, SymptomCheckerState>(
                builder: (context, state) {
                  if (state is SymptomCheckerSuccess) {
                    return _buildResultCard(state.result);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(SymptomAnalysisResult result) {
    final isSevere = result.severityScore.toLowerCase().contains("red") || result.shouldSeeVetNow;
    final color = isSevere ? Colors.red.shade100 : Colors.green.shade100;
    final textColor = isSevere ? Colors.red.shade900 : Colors.green.shade900;

    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isSevere ? Icons.warning : Icons.check_circle, color: textColor),
                const SizedBox(width: 8),
                Text(
                  "Severity: ${result.severityScore}",
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Possible Conditions:",
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            ...result.possibleConditions.map((c) => Text("• ${c.name} (${(c.probability * 100).toInt()}%)")),
            const SizedBox(height: 12),
            Text(
              "Recommendation:",
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            Text(result.actionRecommendation),
            if (result.shouldSeeVetNow) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to telehealth booking
                },
                icon: const Icon(Icons.video_call),
                label: const Text("Book Vet Now"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class _ProviderSettingsDialog extends StatefulWidget {
  final AIService aiService;
  const _ProviderSettingsDialog({required this.aiService});

  @override
  State<_ProviderSettingsDialog> createState() => _ProviderSettingsDialogState();
}

class _ProviderSettingsDialogState extends State<_ProviderSettingsDialog> {
  String _selectedProvider = 'Ollama';
  final TextEditingController _urlController = TextEditingController(text: 'http://10.0.2.2:11434');
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _modelController = TextEditingController(text: 'llava');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("AI Provider Settings"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedProvider,
              items: const [
                DropdownMenuItem(value: 'Ollama', child: Text('Ollama (Local)')),
                DropdownMenuItem(value: 'HuggingFace', child: Text('Hugging Face')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedProvider = value!;
                  if (_selectedProvider == 'Ollama') {
                    _urlController.text = 'http://10.0.2.2:11434';
                    _modelController.text = 'llava';
                  } else {
                    _urlController.text = '';
                    _modelController.text = 'meta-llama/Meta-Llama-3-8B-Instruct';
                  }
                });
              },
              decoration: const InputDecoration(labelText: "Provider"),
            ),
            if (_selectedProvider == 'Ollama')
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: "Base URL"),
              ),
            if (_selectedProvider == 'HuggingFace')
              TextField(
                controller: _keyController,
                decoration: const InputDecoration(labelText: "API Key"),
                obscureText: true,
              ),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(labelText: "Model Name"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedProvider == 'Ollama') {
              widget.aiService.setProvider(OllamaProvider(
                baseUrl: _urlController.text,
                model: _modelController.text,
              ));
            } else {
              widget.aiService.setProvider(HuggingFaceProvider(
                apiKey: _keyController.text,
                model: _modelController.text,
              ));
            }
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Switched to $_selectedProvider")),
            );
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
