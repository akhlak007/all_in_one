# University Companion

A comprehensive Flutter-based mobile app that consolidates essential university services. The app is intuitive, scalable, and optimized for local deployment on Android.

## Features

### 1. Cafeteria Menu & Meal Schedules
- Real-time meal details & prices from Firebase Firestore
- Pre-order meals using Stripe API
- Offline caching for menu access without internet

### 2. University Bus Tracking
- Google Maps API with real-time Firebase database updates
- Bus routes, real-time location, and delay notifications
- Offline mode showing last known bus schedule

### 3. Class Schedules & Faculty Contacts
- Class timetables & faculty contacts from Firebase
- Automated reminders & assignment tracking
- AI-based "Class Assistant" chatbot powered by Gemini AI

### 4. Event & Club Management
- University event calendar with RSVP functionality
- Smart AI-based event recommender using Gemini AI
- Student clubs & activities with direct sign-up options

### 5. Campus Navigation & Augmented Reality (AR) Map
- AR navigation using ARCore & Google Maps
- Building scanning for location details (AR wayfinding)

### Bonus Features
- AI Chatbot Assistant
- Smart Voice Commands
- Offline Mode (MarkMode)
- Security Features (ID-based Access Logs)
- Emergency SOS Button

## Technical Implementation

- **Frontend:** Flutter (Material UI, Riverpod for state management)
- **Backend:** Firebase Firestore (for real-time data storage)
- **Authentication:** Firebase Auth (Google Sign-In, Email/Password)
- **APIs Used:**
  - Google Maps API (Bus Tracking, AR Navigation)
  - Gemini AI API (AI Chatbot & Event Recommender)
  - Stripe API (Meal Pre-order System)
  - Twilio API (Emergency SOS SMS Service)
  - Flutter Speech-to-Text API (Voice Commands)

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Firebase account
- Google Maps API key
- Gemini AI API key

### Setup
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase:
   - Create a new Firebase project
   - Add Android app to the project
   - Download `google-services.json` and place it in the `android/app` directory
4. Configure API keys:
   - Add Google Maps API key in `android/app/src/main/AndroidManifest.xml`
   - Add Gemini AI API key in `lib/services/ai_service.dart`
5. Run the app: `flutter run`

## Building for Production
```bash
flutter build apk --release
```

## License
This project is licensed under the MIT License - see the LICENSE file for details.