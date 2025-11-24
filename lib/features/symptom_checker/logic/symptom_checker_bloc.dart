import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pet_pulse/features/symptom_checker/services/ai_service.dart';
import 'package:pet_pulse/features/symptom_checker/screens/symptom_checker_screen.dart'; // For SymptomAnalysisResult

// Events
abstract class SymptomCheckerEvent extends Equatable {
  const SymptomCheckerEvent();
  @override
  List<Object?> get props => [];
}

class AnalyzeSymptoms extends SymptomCheckerEvent {
  final String symptomDescription;
  final String petType;
  final String breed;
  final String age;
  final String? imagePath;

  const AnalyzeSymptoms({
    required this.symptomDescription,
    required this.petType,
    required this.breed,
    required this.age,
    this.imagePath,
  });

  @override
  List<Object?> get props => [symptomDescription, petType, breed, age, imagePath];
}

// States
abstract class SymptomCheckerState extends Equatable {
  const SymptomCheckerState();
  @override
  List<Object?> get props => [];
}

class SymptomCheckerInitial extends SymptomCheckerState {}

class SymptomCheckerLoading extends SymptomCheckerState {}

class SymptomCheckerSuccess extends SymptomCheckerState {
  final SymptomAnalysisResult result;
  const SymptomCheckerSuccess(this.result);
  @override
  List<Object?> get props => [result];
}

class SymptomCheckerFailure extends SymptomCheckerState {
  final String error;
  const SymptomCheckerFailure(this.error);
  @override
  List<Object?> get props => [error];
}

// BLoC
class SymptomCheckerBloc extends Bloc<SymptomCheckerEvent, SymptomCheckerState> {
  final AIService _aiService;

  SymptomCheckerBloc(this._aiService) : super(SymptomCheckerInitial()) {
    on<AnalyzeSymptoms>(_onAnalyzeSymptoms);
  }

  Future<void> _onAnalyzeSymptoms(
    AnalyzeSymptoms event,
    Emitter<SymptomCheckerState> emit,
  ) async {
    emit(SymptomCheckerLoading());
    try {
      final result = await _aiService.analyzeSymptoms(
        petType: event.petType,
        breed: event.breed,
        age: event.age,
        symptomDescription: event.symptomDescription,
        imagePath: event.imagePath,
      );
      emit(SymptomCheckerSuccess(result));
    } catch (e) {
      emit(SymptomCheckerFailure(e.toString()));
    }
  }
}
