import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_pulse/features/symptom_checker/logic/symptom_checker_bloc.dart';
import 'package:pet_pulse/features/symptom_checker/services/ai_service.dart';

class SymptomCheckerScreen extends StatelessWidget {
  final AIService? aiService;
  
  const SymptomCheckerScreen({super.key, this.aiService});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SymptomCheckerBloc(aiService ?? AIService()),
      child: const _SymptomCheckerView(),
    );
  }
}

class _SymptomCheckerView extends StatefulWidget {
  const _SymptomCheckerView();

  @override
  State<_SymptomCheckerView> createState() => _SymptomCheckerViewState();
}

class _SymptomCheckerViewState extends State<_SymptomCheckerView> {
  final TextEditingController _symptomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Symptom Checker"),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              ),
            ),
            const SizedBox(height: 16),
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
                          ));
                    }
                  },
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
    );
  }

  Widget _buildResultCard(SymptomAnalysisResult result) {
    final isSevere = result.severityScore == "Red" || result.shouldSeeVetNow;
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

