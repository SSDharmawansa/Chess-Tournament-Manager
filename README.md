# Chess Team Director

A Flutter mobile application for managing and organizing chess team tournaments.

## Features

- Create and edit team chess tournaments
- Manage teams, captains, and player rosters
- Support multiple pairing formats through modular pairing engines
- Generate rounds and review pairings
- Enter team and board-by-board results
- Calculate live standings with common tie-break values
- Save tournaments locally for offline use
- Seeded dummy data for testing and demos

## Tech Stack

- Flutter
- Riverpod
- Hive

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
- Offline local storage
- Reusable tournament management UI
- Modular pairing engine design
- Summary/export integration points for future PDF, Excel, and cloud features

## License

Add a license here before publishing if you want others to reuse the project.
