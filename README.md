# Flutter Picture-in-Picture (PiP) Video Player

A modern, production-ready Flutter video streaming application that correctly implements Android's native Picture-in-Picture (PiP) mode. This project demonstrates advanced platform channel communication, app lifecycle state management, responsive UI design, and containerized deployment.

## ✨ Features

* **Native Android PiP:** Utilizes Kotlin and Platform Channels (`MethodChannel`) to trigger Android's native PiP mode seamlessly.
* **State Persistence:** Automatically saves the last video playback position to `SharedPreferences` when the app is backgrounded, resuming exactly where the user left off.
* **API Integration & Caching:** Fetches mock video metadata from a REST endpoint using browser-mimicking headers to bypass firewalls, and caches it to a local `.json` file via `path_provider`.
* **Responsive UI:** Dynamically hides the AppBar and controls when entering PiP mode to prevent layout overflow errors, ensuring a clean, borderless video experience.
* **Robust Error Handling:** Features a custom error UI with retry logic for network failures.
* **Containerized Build:** Includes a Docker and Docker Compose environment to ensure consistent, reproducible release APK builds without local environment dependency issues.

## 🛠️ Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel, ^3.0.0)
* [Docker](https://www.docker.com/products/docker-desktop) and Docker Compose
* Android Studio (with an Emulator running Android 8.0 / API 26 or higher to test PiP capabilities)
* A physical Android device (optional, requires USB debugging and Internet permissions configured).

## 🚀 Environment Setup & Local Development

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd flutter_video_player
   ```
2. **Environment Variables:**
   Ensure you have an environment file set up. Check the `.env.example` file in the root directory for required variables.
   *Note: For local testing, no actual API keys are required as it uses a public mock API.*

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the application:**
   Launch an Android Emulator (API 26+) and execute:
   ```bash
   flutter run
   ```

## 📱 Testing Picture-in-Picture (PiP)
PiP mode requires a native Android environment. It will not function on Flutter Web or Desktop targets.

1. Play the video in the app.
2. Tap the **PiP Icon** below the video player.
3. The app will seamlessly shrink into a floating window. Tap the window to reveal native play/pause controls.
4. Minimize the app completely and reopen it to test lifecycle persistence (the video will resume at your exact timestamp).

## 🐳 Building the Release APK (Docker)
This project is configured to build the release APK inside a clean, isolated Docker container (using the `ghcr.io/cirruslabs/flutter:stable` image) to prevent environment discrepancies.

1. Ensure the Docker daemon (Docker Desktop) is running on your machine.
2. Run the following command from the project root:
   ```bash
   docker-compose up --build
   ```
3. The container will resolve dependencies, download the Android NDK/Build Tools, and compile the code.

Once the process exits with code 0, the generated production APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

## 🧪 Automated Testing
The application includes widget tests to verify the integrity of the UI components and their respective `data-test-id` keys.

To run the tests locally, execute:
```bash
flutter test test/widget/video_player_screen_test.dart
```

## 🏗️ Architecture Notes
* **Native Bridge:** The Android Kotlin implementation for PiP and remote actions is located in `android/app/src/main/kotlin/.../MainActivity.kt`.
* **Data Storage:** Metadata is securely stored in the application's document directory (`app_data/video_metadata.json`).
* **State Management:** The UI uses Flutter's native `StatefulWidget` combined with `WidgetsBindingObserver` to monitor app lifecycle changes and manage the `VideoPlayerController`.
