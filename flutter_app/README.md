# Chinese Flashcard - Flutter App

A beautiful Chinese flashcard learning app with smooth animations built with Flutter.

## Features

✨ **Beautiful Animations**
- Smooth slide transitions between cards
- Fade-in and scale animations
- Shimmer effects on buttons
- Progress indicator animations
- Flip card animations

🎨 **Modern UI**
- Material Design 3
- Gradient backgrounds
- Elevated cards with shadows
- Color-coded feedback (green for correct, red for incorrect)
- Responsive layout

📚 **Learning Features**
- HSK levels 1-6 support
- Patch-based learning system
- Progress tracking
- Pinyin input with tone number support
- Multiple language support (English, Vietnamese, Hán Việt)
- Real-time answer checking

⚙️ **Configuration**
- Adjustable HSK level
- Customizable words per patch
- Progress reset option
- Settings persistence

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)

### Installation

1. Navigate to the flutter_app directory:
```bash
cd flutter_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── chinese_word.dart     # Word data model
├── services/
│   └── data_service.dart     # Data management & persistence
└── screens/
    ├── home_screen.dart      # Main menu with animations
    ├── flashcard_screen.dart # Learning/testing interface
    └── config_screen.dart    # Settings screen
```

## Packages Used

- **flutter_animate**: Advanced animations
- **google_fonts**: Beautiful typography (Noto Sans)
- **flip_card**: Card flip animations
- **shared_preferences**: Local data persistence
- **csv**: CSV file parsing
- **path_provider**: File system access

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Animations

The app features multiple types of animations:

1. **Entry Animations**: Fade-in and slide effects when screens load
2. **Shimmer Effects**: Subtle shine effects on interactive buttons
3. **Scale Animations**: Growing effects for emphasis
4. **Slide Transitions**: Smooth horizontal slides between cards
5. **Progress Animations**: Animated progress bars
6. **Success/Error Animations**: Bouncing icons with shake effects

## License

This project is part of the Chinese Learning repository.
