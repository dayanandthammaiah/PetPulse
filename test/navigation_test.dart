import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_pulse/main.dart';
import 'package:pet_pulse/features/home/screens/home_screen.dart';
import 'package:pet_pulse/features/symptom_checker/screens/symptom_checker_screen.dart';
import 'package:pet_pulse/features/subscription/screens/paywall_screen.dart';
import 'package:pet_pulse/features/symptom_checker/services/ai_service.dart';
import 'package:pet_pulse/features/subscription/services/subscription_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// Mocks
class MockAIService extends AIService {
  @override
  Future<SymptomAnalysisResult> analyzeSymptoms({
    required String petType,
    required String breed,
    required String age,
    required String symptoms,
    String? imageUrl,
  }) async {
    return SymptomAnalysisResult(
      possibleConditions: [],
      severityScore: "Green",
      actionRecommendation: "Rest",
      shouldSeeVetNow: false,
    );
  }
}

class MockSubscriptionService extends SubscriptionService {
  @override
  Future<List<Package>> getOfferings() async => [];
  
  @override
  Future<bool> checkSubscriptionStatus() async => false;
}

void main() {
  testWidgets('App navigation works correctly', (WidgetTester tester) async {
    // Create a test router with mocked services
    final testRouter = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => HomeScreen(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const Scaffold(body: Text("Home Feed Content")),
            ),
            GoRoute(
              path: '/scanner',
              builder: (context, state) => SymptomCheckerScreen(aiService: MockAIService()),
            ),
            GoRoute(
              path: '/shop',
              builder: (context, state) => PaywallScreen(subscriptionService: MockSubscriptionService()),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(PetPulseApp(router: testRouter));
    await tester.pumpAndSettle();

    // 1. Verify Home Screen
    expect(find.text("Home Feed Content"), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);

    // 2. Navigate to Scanner
    await tester.tap(find.byIcon(Icons.health_and_safety_outlined));
    await tester.pumpAndSettle();
    
    expect(find.byType(SymptomCheckerScreen), findsOneWidget);
    expect(find.text("AI Symptom Checker"), findsOneWidget);

    // 3. Navigate to Shop (Paywall)
    await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(PaywallScreen), findsOneWidget);
    expect(find.text("Unlock PetPulse Pro"), findsOneWidget);
  });
}
