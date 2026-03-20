# Chess Team Director

A Flutter mobile application for managing and organizing chess team tournaments.

## Features

- Create and edit team chess tournaments
- Manage teams, captains, and player rosters
- Support multiple pairing formats through modular pairing engines
- Generate rounds and review pairings
- Enter team and board-by-board results
- Calculate live standings with common tie-break values
- Store tournaments in Firebase Cloud Firestore
- Seeded dummy data for testing and demos

## Tech Stack

- Flutter
- Firebase Core
- Cloud Firestore
- Riverpod

## Project Structure

```text
lib/
  core/
  dummy_data/
  models/
  pairing_engines/
  screens/
  services/
  state/
  storage/
  widgets/
```

## Getting Started

### Prerequisites

- Flutter SDK
- Android Studio or VS Code with Flutter support
- Android emulator or physical device

### Run the app

```bash
flutter pub get
flutter run
```

## Firebase Setup

Tournament data now lives in the Firestore `tournaments` collection.

- The current app bootstrap in `lib/firebase_options.dart` targets the Firebase project `chess-tournament-manager-70540`.
- If you want to point the app at a different Firebase project, rerun `flutterfire configure` and replace the generated values in `lib/firebase_options.dart`.
- The current Dart bootstrap is configured for Android, iOS, and macOS. Web and Windows still need explicit FlutterFire configuration before they can initialize Firebase.
- Because the app does not currently sign users in, your Firestore rules must allow the app to read and write the `tournaments` collection during development.

Example development rule:

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /tournaments/{tournamentId} {
      allow read, write: if true;
    }
  }
}
```

### Run checks

```bash
flutter analyze
flutter test
```

## Android Note

The Gradle wrapper is configured to use a project-local Gradle cache so the project can build cleanly even when the global Gradle cache is not writable.

## Current Scope

This repository includes:

- Full Flutter app scaffold
- Firebase-backed tournament storage
- Reusable tournament management UI
- Modular pairing engine design
- Summary/export integration points for future PDF, Excel, and cloud features

## License

Add a license here before publishing if you want others to reuse the project.
