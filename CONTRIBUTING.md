# Contributing to Liser 🎵

First off, thank you for considering contributing to Liser! It's people like you that make the open-source community such a fantastic place to learn, inspire, and create.

## 🛠 How Can I Contribute?

### 1. Reporting Bugs
This section guides you through submitting a bug report for Liser. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.
- Use the GitHub Issue Tracker to report bugs.
- Clearly describe the issue, including steps to reproduce, expected behavior, and actual behavior.
- Include information about your device, OS version, and Flutter version.

### 2. Suggesting Enhancements
Enhancement suggestions are tracked as GitHub issues.
- Use a clear and descriptive title for the issue to identify the suggestion.
- Provide a step-by-step description of the suggested enhancement.
- Explain why this enhancement would be useful to most users.

### 3. Submitting Pull Requests
1. **Fork the repository** on GitHub.
2. **Clone your fork** locally: `git clone https://github.com/yourusername/liser.git`
3. **Create a branch** for your edits: `git checkout -b feature/your-feature-name`
4. **Make your changes** and ensure they follow the coding style (see below).
5. **Commit your changes**: `git commit -m 'feat: Add some feature'`
6. **Push to your fork**: `git push origin feature/your-feature-name`
7. **Submit a Pull Request** to the `dev` branch of the original repository.

---

## 💻 Coding Guidelines

To ensure consistency throughout the source code, keep these rules in mind as you are working:

- **Follow Dart Conventions:** Use the [Effective Dart](https://dart.dev/guides/language/effective-dart) guide.
- **Linting:** Run `flutter analyze` before committing. Ensure your code does not introduce new warnings.
- **State Management:** We heavily rely on `flutter_bloc`. Ensure new features respect the established architectural patterns (UI -> Bloc -> Repository -> Service).
- **Native Code:** If you write Swift/Kotlin code (e.g. for `AppDelegate.swift` or `MainActivity.kt`), clearly document what the platform channels are doing and why.

---

## 🏗 Setup for Local Development

1. Ensure you have the Flutter SDK installed and configured.
2. Clone the repository and run `flutter pub get`.
3. If you make changes to models, regenerate Hive adapters using:
   `flutter packages pub run build_runner build --delete-conflicting-outputs`
4. Test thoroughly on both iOS Simulators and Android Emulators before submitting a PR.

Thank you for your contributions! 🚀
