🗺️ Travvel - Travel Destination Manager
A comprehensive Flutter mobile application for managing travel destinations with real-time route navigation and location search powered by Google Maps APIs.

---

📱 Features
Core Features:

✅ Destination Management

-Add, edit, and delete travel destinations
-Store destination details (name, description, coordinates, photos, opening hours)
-View destinations in list and map view

🗺️ Interactive Maps

-View all destinations on Google Maps
-Real-time route navigation with turn-by-turn directions
-Distance and duration calculation via road networks
-Live location tracking

🔍 Smart Search

-Search destinations from database
-Google Places API integration for discovering new places
-Autocomplete suggestions while typing

📸 Photo Management

-Add photos from camera or gallery
-Local storage for offline access

📍 Location Services

-Pick location from map with search
-Use current GPS location
-Manual coordinate input

---

🏗️ Architecture
Tech Stack:

-Framework: Flutter 3.6.0
-Language: Dart 3.6.0
-State Management: Stateful Widgets
-Database: SQLite (sqflite)
-Maps: Google Maps Flutter
-HTTP Client: Dio
-Responsive UI: Sizer

Project Structure:

travvel/
├── android/ # Android platform files
│ ├── app/
│ │ ├── src/main/
│ │ │ ├── AndroidManifest.xml
│ │ │ └── kotlin/
│ │ └── build.gradle.kts
│ └── local.properties # Google Maps API Key (gitignored)
│
├── lib/
│ ├── core/ # Core utilities
│ │ └── app_export.dart
│ │
│ ├── presentation/ # UI Screens
│ │ ├── splash_screen/
│ │ ├── home_screen/
│ │ ├── add_destination_screen/
│ │ ├── edit_destination_screen/
│ │ ├── destination_detail_screen/
│ │ ├── map_view_screen/
│ │ └── api_test_screen/ # Debug helper
│ │
│ ├── services/ # Business Logic
│ │ ├── database_helper.dart
│ │ ├── directions_service.dart
│ │ └── place_search_service.dart
│ │
│ ├── routes/ # Navigation
│ │ └── app_routes.dart
│ │
│ ├── theme/ # Styling
│ │ └── app_theme.dart
│ │
│ ├── widgets/ # Reusable Components
│ │ ├── custom_app_bar.dart
│ │ ├── custom_bottom_bar.dart
│ │ ├── custom_icon_widget.dart
│ │ └── custom_image_widget.dart
│ │
│ └── main.dart # Entry point
│
├── assets/
│ └── images/ # App assets
│
├── pubspec.yaml # Dependencies
└── README.md # This file

---

🔧 Requirements
System Requirements:

-OS: Windows 10+, macOS 10.14+, or Linux
-RAM: Minimum 8GB (16GB recommended)
-Storage: 10GB free space
-Internet: Required for API calls

Software Requirements:

-Flutter SDK 3.6.0 or higher
-Dart SDK 3.6.0 or higher
-Android Studio / VS Code with Flutter extensions
-Android SDK (for Android development)
-Xcode (for iOS development, macOS only)

API Requirements:

Google Maps API Key with the following APIs enabled:

-✅ Maps SDK for Android
-✅ Directions API
-✅ Places API

Active Google Cloud Billing Account
