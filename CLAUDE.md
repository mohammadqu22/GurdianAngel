# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Guardian Angel** is a Flutter mobile app targeting both **iOS and Android** that guides users through first-aid emergency protocols step by step. It covers 6 emergencies: CPR, bleeding, burns, choking, fractures, and seizures. The app was built as an academic final-year project at Azrieli College of Engineering, Jerusalem.

This is a two-person collaborative project. Both developers contribute across all areas of the codebase as needed.

macOS desktop is **not** a target platform. Ignore the `macos/` directory.

## UI Design Reference

The target UI is designed in Google Stitch (project ID: 18416799649176081778). All screen improvements should align with the Stitch mockups. The design uses deep red (#E53935) as the primary brand color, with per-emergency accent colors: orange for Burns, blue for Choking, dark red for Bleeding, purple for Fractures, and amber for Seizures.

## Known Bugs

**Location sharing crash (high priority):** Tapping "Share My Location" in Settings causes the app to freeze and throws an unhandled exception. Root cause: `ios/Runner/Info.plist` is missing the required iOS permission keys `NSLocationWhenInUseUsageDescription` and `NSLocationAlwaysUsageDescription`. Fix: add both keys with descriptive strings to Info.plist before the closing `</dict>` tag.

**App name typo in config files:** The app name is misspelled as "Gurdian Angel" (missing the 'a' in Guardian) in several platform config files including `ios/Runner/Info.plist` and macOS/Windows configs. This is a known issue from the original project setup. Do not silently rename — ask before fixing.

## Common Commands
```bash
# Install dependencies
flutter pub get

# Run on connected device or simulator
flutter run

# Build iOS release
flutter build ios

# Analyze (lint)
flutter analyze

# Run tests
flutter test
```

## Architecture

### App Startup Flow (`lib/main.dart`)
1. `DatabaseService.initialize()` sets up SQLite tables
2. `PermissionService` requests `phone` and `location` permissions
3. `SharedPreferences` checks `disclaimer_accepted` key
4. Routes to `DisclaimerScreen` (first launch) or `HomeScreen` (returning users)

### Navigation Model
All navigation uses `Navigator.push()` — there is no named route system. The files `lib/core/routes.dart` and `lib/core/constants.dart` exist but are **empty placeholders**. Do not assume named routes exist.

### Emergency Protocol Data Flow
- 6 JSON files live in `assets/data/` (bleeding, burns, choking, cpr, fractures, seizures)
- `lib/models/emergency.dart` holds the `Emergency` class and a hardcoded list of 6 entries returned by `getSampleEmergencies()`
- `StepScreen` loads the matching JSON at runtime via `rootBundle.loadString('assets/data/{id}.json')` — there is no separate loader service (`protocol_loader.dart` is empty)

### JSON Protocol Format
```json
{
  "id": "cpr",
  "title": "CPR",
  "steps": [{ "step": 1, "title": "...", "instruction": "..." }],
  "warnings": ["..."],
  "sources": ["..."]
}
```

### Persistence
`lib/services/database_service.dart` — singleton SQLite via `sqflite` with three tables:
- `User_Settings` — language preference and TTS toggle
- `Emergency_Contact` — name + phone, supports add/edit/delete/call
- `Incident_Log` — timestamped log entries (table exists, no UI yet)

`SharedPreferences` is used for lightweight flags: `disclaimer_accepted`, `language`, `tts_enabled`.

### Services
| File | Status | Purpose |
|---|---|---|
| `database_service.dart` | Implemented | SQLite CRUD |
| `permission_service.dart` | Implemented | Phone + location permissions |
| `location_service.dart` | Implemented | GPS coords + Google Maps link |
| `tts_service.dart` | **Empty** | `flutter_tts` is a dependency but TTS is not implemented |
| `protocol_loader.dart` | **Empty** | JSON loading is done inline in `StepScreen` |

### Widgets
`lib/widgets/emergency_card.dart` and `lib/widgets/step_widget.dart` are **empty**. All UI is built inline inside the screen files. These are candidates for extraction when improving the UI.

## Known Incomplete Areas

**TTS** is the most critical missing feature: `flutter_tts` is in `pubspec.yaml` and the toggle exists in Settings, but `tts_service.dart` is empty and no screen calls it.

**Internationalization**: Settings UI offers English, Hebrew, and Arabic selection, but the language preference is saved and never applied to the UI.

**Incident Log UI**: The `Incident_Log` table is created and writable but there is no screen to display history.

**`emergency_detail_screen.dart`**: Partially implemented with TODO comments. Navigation bypasses it entirely — `HomeScreen` goes directly to `StepScreen`.

**Tests**: `test/widget_test.dart` references a `MyApp` class that no longer exists and will not pass.