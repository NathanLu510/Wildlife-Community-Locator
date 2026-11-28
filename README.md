# Wildlife Community Locator

A community-driven mobile application for discovering, locating, and sharing wildlife sightings through an interactive geographical map.

Initially focused on Taiwan, the project aims to expand into a global wildlife observation platform.

## Core Features

- Interactive wildlife map with selectable regional boundaries.
- Species discovery, search, and category-based filtering.
- Wildlife sighting submission with photographs, GPS coordinates, and descriptions.
- Automatic regional classification using a ray-casting point-in-polygon algorithm.
- Dynamic wildlife sighting markers and regional observation panels.

## Technologies

- Flutter & Dart
- flutter_map & latlong2
- GeoJSON
- CARTO & OpenStreetMap
- Geolocator
- Image Picker

## Future Development

- Persistent storage and cloud database integration.
- User accounts and community interaction.
- AI-powered wildlife species identification.
- Automated image moderation.
- AI-powered wildlife information assistant.
- Sensitive species location protection.
- Global geographical expansion.

## Project Status

**Early-stage development (Pre-alpha)**

Currently developed primarily for Android. Sighting submission is implemented but awaits full end-to-end testing. Observations are currently stored in memory, with persistent storage and backend integration planned.

run application with:
flutter run --dart-define=CARTO_API_KEY=cb1_4m8g_1_2ec33c7fea0a823e13338ebe
