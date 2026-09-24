# melai_nuts

A Prototype

## Setup: Firebase keys (required)

Firebase API keys are **not committed**. Before running:

```bash
cp env/firebase.example.json env/firebase.json          # then fill in your keys
cp android/app/google-services.json.example android/app/google-services.json  # Android only

flutter run --dart-define-from-file=env/firebase.json
flutter build apk --dart-define-from-file=env/firebase.json
```

`env/firebase.json` and `android/app/google-services.json` are git-ignored.
See [SECURITY.md](SECURITY.md) for key restriction and rotation.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
