# Phase 2 — Mobile App UI (User Side)
## Android Flutter Application

---

## Context
This is the user-facing side of a Room Scheduling System. The backend is already built and live. The Flutter app needs to consume the existing REST API and display available rooms to users. No authentication is required on the user side.

---

## API

**Endpoint:**
```
GET https://<your-api-id>.execute-api.ap-southeast-1.amazonaws.com/prod/rooms
```

**Query Parameters:**
| Parameter | Type   | Example     |
|-----------|--------|-------------|
| day       | String | MONDAY      |
| time      | String | 9:00 AM     |

**Response:**
```json
{
  "available_now": [
    { "room": "1902", "vacant_until": "10:00 AM", "vacant_for": "1h 0m" },
    { "room": "1901", "vacant_until": "11:30 AM", "vacant_for": "2h 30m" }
  ],
  "available_soon": [
    { "room": "1904", "vacant_in": "2h 30m", "at": "11:30 AM" }
  ]
}
```

---

## Goals
- Display rooms available at the current day and time on app open
- Allow user to manually filter by day and time
- Show room details — vacant until, vacant for, and available soon
- Clean, fast UI with no login required

---

## Folder Structure
```
lib/
├── main.dart
├── screens/
│   ├── home_screen.dart            # Available rooms at current time
│   └── filter_screen.dart          # Manual day/time picker
├── widgets/
│   ├── room_card.dart              # Individual room display card
│   └── available_soon_card.dart    # Upcoming available room card
├── services/
│   └── api_service.dart            # GET /rooms API call logic
└── models/
    └── room.dart                   # Data model for room response
```

---

## Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0        # API calls
  intl: ^0.19.0       # Date/time formatting
```

---

## Considerations
- **Auto-query on open** — call the API immediately on app launch using the current day and time
- **Time format** — API expects `9:00 AM` format (12-hour with space before AM/PM), ensure Flutter formats `DateTime` accordingly using `intl`
- **Pull to refresh** — user can pull down to refresh room availability
- **Empty state** — show a message when no rooms are available
- **Error state** — handle API timeout or failure gracefully with a user-friendly message
- **No auth** — GET /rooms is fully public, no token needed
- **CORS** — not needed for native iOS, revisit if a web version is built later

---

## Screens

### home_screen.dart
- On load, get current day and time
- Call `api_service.dart` with current day and time
- Display `available_now` rooms as a list of `room_card` widgets
- Display `available_soon` rooms as a list of `available_soon_card` widgets
- Show loading indicator while fetching
- Show empty state if both lists are empty
- Support pull to refresh

### filter_screen.dart
- Day picker — dropdown or segmented control (MONDAY to SATURDAY)
- Time picker — iOS style time picker
- On submit, call API with selected day and time
- Display results same as home screen

---

## Data Models

### Room (available_now)
```dart
class RoomNow {
  final String room;
  final String vacantUntil;
  final String vacantFor;
}
```

### Room (available_soon)
```dart
class RoomSoon {
  final String room;
  final String vacantIn;
  final String at;
}
```
