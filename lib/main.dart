import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pet_pulse/features/home/screens/home_screen.dart';
import 'package:pet_pulse/features/symptom_checker/screens/symptom_checker_screen.dart';
import 'package:pet_pulse/features/subscription/screens/paywall_screen.dart';
// import 'firebase_options.dart'; // Uncomment when firebase is configured

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PetPulseApp());
}

class PetPulseApp extends StatelessWidget {
  final GoRouter? router;
  
  const PetPulseApp({super.key, this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PetPulse',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: router ?? _router,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    var baseTheme = ThemeData(brightness: brightness);
    
    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C63FF), // Primary Pastel Purple
        brightness: brightness,
        secondary: const Color(0xFFFF6584), // Pastel Pink
        tertiary: const Color(0xFF4ECDC4), // Pastel Teal
      ),
      textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme),
      useMaterial3: true,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return HomeScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Center(child: Text("Home - Breed Feed (Coming Soon)"))),
        ),
        GoRoute(
          path: '/scanner',
          builder: (context, state) => const SymptomCheckerScreen(),
        ),
        GoRoute(
          path: '/records',
          builder: (context, state) => const Scaffold(body: Center(child: Text("Health Records (Coming Soon)"))),
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) => const Scaffold(body: Center(child: Text("Pet Map (Coming Soon)"))),
        ),
        GoRoute(
          path: '/shop',
          builder: (context, state) => const PaywallScreen(), // Using Paywall as Shop/Pro placeholder for now
        ),
      ],
    ),
  ],
);
