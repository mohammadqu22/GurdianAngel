# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Guardian Angel** is a Flutter mobile app targeting both **iOS and Android** that guides users through first-aid emergency protocols step by step. It covers 8 emergency types: CPR, CPR (infant), bleeding, burns, choking, choking (infant), fractures, and seizures. The app was built as an academic final-year project at Azrieli College of Engineering, Jerusalem.

This is a two-person collaborative project. Both developers contribute across all areas of the codebase as needed.

macOS desktop is **not** a target platform. Ignore the `macos/` directory.

## UI Design Reference

The target UI is designed in Google Stitch (project ID: 18416799649176081778). All screen improvements should align with the Stitch mockups. The design uses deep red (#E53935) as the primary brand color, with per-emergency accent colors: orange for Burns, blue for Choking, dark red for Bleeding, purple for Fractures, and amber for Seizures.

## Known Bugs

**App name typo in config files:** The app name is misspelled as "Gurdian Angel" (missing the 'a' in Guardian) in some platform config files. Do not silently rename — ask before fixing.

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
1. `DatabaseService.database` initializes SQLite tables
2. `TtsService.instance.init()` initializes the TTS engine
3. `SharedPreferences` loads `disclaimer_accepted`, `theme_mode`, and `language` preferences
4. `PermissionService.requestAppPermissions()` requests phone and location permissions (non-blocking)
5. Routes to `DisclaimerScreen` (first launch) or `HomeScreen` (returning users)

### Navigation Model
All navigation uses `Navigator.push()` — there is no named route system. The files `lib/core/routes.dart` and `lib/core/constants.dart` exist but are **empty placeholders**. Do not assume named routes exist.

### Emergency Protocol Data Flow
- JSON protocol files are organized into three language directories:
  - `assets/data/` — English (8 files: bleeding, burns, choking, choking_infant, cpr, cpr_infant, fractures, seizures)
  - `assets/data/he/` — Hebrew (same 8 files)
  - `assets/data/ar/` — Arabic (same 8 files)
- `StepScreen` tries to load the locale-specific file first, then falls back to English — there is no separate loader service (`protocol_loader.dart` is empty)
- `lib/models/emergency.dart` holds the `Emergency` class; the emergency list is built dynamically in `HomeScreen` using localized strings

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
- `Incident_Log` — timestamped log entries (table exists, not wired to any UI or call sites)

`SharedPreferences` is used for lightweight flags: `disclaimer_accepted`, `language`, `tts_enabled`, `theme_mode`.

### Services
| File | Status | Purpose |
|---|---|---|
| `database_service.dart` | Implemented | SQLite CRUD |
| `permission_service.dart` | Implemented | Phone + location permissions |
| `location_service.dart` | Implemented | GPS coords + Google Maps link |
| `phone_service.dart` | Implemented | Initiates phone calls via `tel:` URI; used for SOS (101) and emergency contacts |
| `tts_service.dart` | Implemented | Singleton audio player via `audioplayers`; plays pre-recorded MP3s from `assets/audio/` |
| `protocol_loader.dart` | **Empty** | JSON loading is done inline in `StepScreen` |

### Widgets
| File | Status | Purpose |
|---|---|---|
| `gradient_button.dart` | Implemented | Reusable primary action button with gradient background |
| `source_item.dart` | Implemented | Row widget for displaying a medical source entry |
| `emergency_card.dart` | **Empty** | Candidate for extraction from `HomeScreen` |
| `step_widget.dart` | **Empty** | Candidate for extraction from `StepScreen` |

## Known Incomplete Areas

**Incident Log UI**: The `Incident_Log` table and its CRUD methods (`logIncident`, `getIncidentLog`, `clearIncidentLog`) exist in `database_service.dart`, but there is no UI screen and `logIncident` is never called anywhere in the app.

**Tests**: `test/widget_test.dart` is an unmodified Flutter template test — it references counter-app logic (tap `Icons.add`, expect count) that has nothing to do with Guardian Angel. It will not pass.

## Internationalization

Language selection (English / Hebrew / Arabic) is fully wired end-to-end:
- User picks a language in `SettingsScreen`; it is saved to SharedPreferences key `'language'`
- `GuardianAngelApp` applies it as the `locale` property on `MaterialApp` and updates on change
- `StepScreen` reloads the protocol JSON for the new locale via `didChangeDependencies()`
- TTS uses matching language codes: `en-US`, `he-IL`, `ar-SA`

On iOS, TTS uses `setVoice` (via `getVoices`) rather than `setLanguage` alone to reliably activate non-English voices. The Arabic/Hebrew TTS voice must be installed on the device: **Settings → Accessibility → Spoken Content → Voices**.
