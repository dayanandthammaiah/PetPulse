# PetPulse 🐾

PetPulse is a comprehensive, cross-platform pet health and community application built with Flutter. It aims to empower pet parents with AI-driven health insights, a vibrant community feed, and essential tools for pet care.

## 📱 Features

### 1. AI Symptom Checker (`/scanner`)
*   **How it works**: Uses Google's Generative AI (Gemini) to analyze reported symptoms.
*   **Usage**:
    1.  Navigate to the **Scanner** tab.
    2.  Enter your pet's details (Type, Breed, Age).
    3.  Describe the symptoms in the text field (e.g., "My dog is limping and has a dry nose").
    4.  Tap **Analyze Health Risk**.
    5.  View the **Severity Score** (Red/Green), **Possible Conditions**, and **Recommendations**.
    6.  If severe, a **Book Vet Now** option appears (simulated).

### 2. PetPulse Pro Subscription (`/shop`)
*   **How it works**: Integrated with RevenueCat for in-app subscriptions.
*   **Usage**:
    1.  Navigate to the **Shop** tab (currently serves as the Pro upgrade page).
    2.  View available subscription packages (fetched from RevenueCat).
    3.  Tap a package to simulate a purchase.
    4.  Unlock premium features like "Unlimited AI Scans".

### 3. Breed-Specific Social Feed (Coming Soon)
*   **Goal**: A social feed tailored to your pet's breed.
*   **Status**: Placeholder on Home tab.

### 4. Health Records & Map (Coming Soon)
*   **Goal**: Track vaccinations/vet visits and find local pet services.
*   **Status**: Placeholders on Records and Map tabs.

---

## 🛠 Technical Architecture

The project follows a **Feature-First** architecture with **Clean Architecture** principles.

### Directory Structure
```
lib/
├── features/               # Feature modules
│   ├── home/               # Home screen & Shell navigation
│   ├── symptom_checker/    # AI Scanner logic (Bloc + Service + UI)
│   └── subscription/       # RevenueCat logic (Service + UI)
├── main.dart               # Entry point, Theme, and Router config
```

### Key Technologies
*   **Framework**: Flutter (SDK >=3.2.0 <4.0.0)
*   **State Management**: `flutter_bloc`
*   **Navigation**: `go_router`
*   **AI/ML**: `google_generative_ai` (Gemini API)
*   **Backend/Auth**: `firebase_core`, `firebase_auth`, `cloud_firestore`
*   **Monetization**: `purchases_flutter` (RevenueCat)
*   **UI**: Material 3, `google_fonts` (Outfit), `font_awesome_flutter`

---

## 🚀 Getting Started

### Prerequisites
1.  **Flutter SDK**: Ensure you have Flutter installed (`flutter doctor`).
2.  **Firebase Project**:
    *   Create a project in the [Firebase Console](https://console.firebase.google.com/).
    *   Add Android/iOS apps and download `google-services.json` / `GoogleService-Info.plist`.
    *   Enable Authentication and Firestore.
3.  **API Keys**:
    *   **Gemini API**: Get an API key from [Google AI Studio](https://makersuite.google.com/).
    *   **RevenueCat**: Create a project in [RevenueCat](https://www.revenuecat.com/) and get your public SDK key.

### Configuration
1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/pet_pulse.git
    cd pet_pulse
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Environment Setup**:
    *   *Note: You may need to configure `firebase_options.dart` using `flutterfire configure`.*
    *   Add your API keys in the respective service files (or use environment variables/`flutter_dotenv`).
        *   `lib/features/symptom_checker/services/ai_service.dart` (Gemini Key)
        *   `lib/features/subscription/services/subscription_service.dart` (RevenueCat Key)

### Running the App
```bash
# Run on connected device or emulator
flutter run
```

---

## 🧪 Testing

Run unit and widget tests:
```bash
flutter test
```

## 🤝 Contributing
1.  Fork the project.
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.
