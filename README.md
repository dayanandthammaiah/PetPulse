# PetPulse 🐾

**Core Requirement**: This app remains fully operational using only free and open-source AI models, tools, and data sources. No functionality is locked behind paid AI backends.

PetPulse is a comprehensive, cross-platform pet health and community application built with Flutter. It empowers pet parents with AI-driven health insights using **local and open-source models**.

---

## 🧠 Open Source AI Architecture

### **AI Provider System**
The app uses a **pluggable AI provider architecture** that supports:

1. **Ollama (Local, Default)** - Completely free, private, offline-capable
   - Model: `llava` (vision) or `llama3` (text)
   - Endpoint: `http://10.0.2.2:11434` (Android emulator) or `http://localhost:11434`
   - Setup: [Install Ollama](https://ollama.ai) and run `ollama pull llava`

2. **Hugging Face (Cloud, Free)** - Open-source models via free Inference API
   - Model: `meta-llama/Meta-Llama-3-8B-Instruct`
   - Requires: Free API token from [Hugging Face](https://huggingface.co/settings/tokens)

3. **Switchable via Settings** - Users can change providers in-app

### **Provider Interface**
See [`lib/features/symptom_checker/services/ai_provider.dart`](file:///i:/PetPulse/lib/features/symptom_checker/services/ai_provider.dart) for the abstraction layer.

---

## 📱 Features

### 1. **AI Symptom Checker** (`/scanner`)
**How it works**: Analyzes pet symptoms using open-source vision and language models.

**Usage**:
1. Navigate to the **Scanner** tab
2. Describe symptoms (e.g., "Red eyes, scratching")
3. **Upload an image** (optional) - wounds, skin issues, etc.
4. Tap **Analyze Health Risk**
5. View **Severity Score** (Red/Green), **Possible Conditions**, and **Recommendations**
6. If severe, **Book Vet Now** option appears

**Configure AI Provider**:
- Tap the **Settings** icon in the app bar
- Choose **Ollama** (local) or **Hugging Face** (cloud)
- Enter endpoint URL or API key

### 2. **PetPulse Pro Subscription** (`/shop`)
Integrated with RevenueCat for in-app subscriptions (optional monetization).

### 3. **Breed-Specific Social Feed** (Coming Soon)
### 4. **Health Records & Map** (Coming Soon)

---

## 🛠 Technical Stack

### **Architecture**
Feature-First with Clean Architecture (Bloc pattern)

```
lib/
├── features/
│   ├── symptom_checker/
│   │   ├── services/
│   │   │   ├── ai_provider.dart          # Abstract interface
│   │   │   ├── ollama_provider.dart      # Local implementation
│   │   │   ├── hugging_face_provider.dart # Cloud implementation
│   │   │   └── ai_service.dart           # Facade
│   │   ├── logic/symptom_checker_bloc.dart
│   │   └── screens/symptom_checker_screen.dart
│   ├── subscription/
│   └── home/
└── main.dart
```

### **Technologies**
- **Framework**: Flutter 3.19.0+
- **State Management**: `flutter_bloc`
- **Navigation**: `go_router`
- **AI/ML**: Ollama REST API, Hugging Face Inference API
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Image Picker**: `image_picker`
- **Monetization**: RevenueCat

---

## 🚀 Getting Started

### **Prerequisites**
1. **Flutter SDK**: `flutter doctor` to verify installation
2. **Ollama** (Recommended for AI):
   ```bash
   # Install from https://ollama.ai
   ollama pull llava
   ollama serve  # Starts on localhost:11434
   ```
3. **Firebase** (Optional for Auth/DB):
   - Create project in [Firebase Console](https://console.firebase.google.com/)
   - Run `flutterfire configure` to generate `firebase_options.dart`

### **Installation**
```bash
git clone https://github.com/dayanandthammaiah/PetPulse.git
cd PetPulse
flutter pub get
```

### **Running**
```bash
# Web
flutter run -d chrome

# Android (requires Android Studio/SDK)
flutter run -d <device-id>

# iOS (requires macOS + Xcode)
flutter run -d <device-id>
```

---

## 🧪 Testing

All tests use mock AI providers:
```bash
flutter test
```

---

## 📦 Building for Production

### **Web**
```bash
flutter build web
# Output: build/web/
```

### **Android APK**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### **iOS** (macOS only)
```bash
flutter build ios --release --no-codesign
# Output: build/ios/iphoneos/Runner.app
```

---

## 🔧 Configuration

### **AI Provider Setup**

#### Option 1: Ollama (Local, Recommended)
1. Install Ollama: `brew install ollama` or download from [ollama.ai](https://ollama.ai)
2. Pull model: `ollama pull llava`
3. In app Settings, set URL to `http://10.0.2.2:11434` (Android emulator) or `http://localhost:11434`

#### Option 2: Hugging Face (Cloud)
1. Get free API token: [Hugging Face Tokens](https://huggingface.co/settings/tokens)
2. In app Settings, select **Hugging Face**, enter token
3. Model defaults to `meta-llama/Meta-Llama-3-8B-Instruct`

### **Firebase Setup** (Optional)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

---

## 🤝 Contributing

1. Fork the project
2. Create feature branch: `git checkout -b feature/AmazingFeature`
3. Commit changes: `git commit -m 'Add AmazingFeature'`
4. Push: `git push origin feature/AmazingFeature`
5. Open Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

## ⚙️ CI/CD

GitHub Actions workflow builds:
- **Android APK** (`.github/workflows/build.yml`)
- **iOS App** (macOS runner)
- **Web** (static files)

Artifacts are uploaded for download after each push to `main`.
