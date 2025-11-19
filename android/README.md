# Chinese Flashcard Android App

A simple and effective Android app for learning Chinese vocabulary using the flashcard method with HSK word lists.

## Features

- 📚 **Learn Current Patch**: Study words with endless shuffle mode
- 🔄 **Start with Revision**: Practice only the words you got wrong
- ⬅️➡️ **Navigation**: Move between word patches
- ✏️ **Test Previous Patches**: Test yourself on learned words
- ✅ **Test Revision**: Test revision words and remove mastered ones
- ⚙️ **Configuration**: Customize HSK level and words per patch
- 💾 **Auto-save Progress**: Your progress is automatically saved
- 🎨 **Color Feedback**: Green for correct, red for incorrect answers
- 🌟 **Highlighted Chinese**: Chinese characters are displayed in cyan/bold

## App Structure

```
android/
├── app/
│   ├── build.gradle                          # App dependencies
│   ├── src/main/
│   │   ├── AndroidManifest.xml              # App configuration
│   │   ├── java/com/chinese/flashcard/
│   │   │   ├── MainActivity.java            # Main menu with buttons
│   │   │   ├── FlashcardActivity.java       # Learning screen
│   │   │   ├── TestActivity.java            # Testing screen
│   │   │   ├── ConfigActivity.java          # Configuration screen
│   │   │   ├── FlashcardManager.java        # Core logic
│   │   │   └── ChineseWord.java             # Word model
│   │   ├── res/
│   │   │   ├── layout/
│   │   │   │   ├── activity_main.xml        # Main menu UI
│   │   │   │   ├── activity_flashcard.xml   # Learning UI
│   │   │   │   └── activity_config.xml      # Config UI
│   │   │   ├── values/
│   │   │   │   ├── strings.xml              # App strings
│   │   │   │   └── themes.xml               # App theme
│   │   └── assets/
│   │       ├── hsk1.csv                     # HSK 1 word list
│   │       └── hsk2.csv                     # HSK 2 word list
├── build.gradle                              # Project build config
└── settings.gradle                           # Project settings
```

## How to Build

### Option 1: Using Android Studio (Recommended)

1. **Install Android Studio**
   - Download from: https://developer.android.com/studio
   - Install with default settings

2. **Open Project**
   - Open Android Studio
   - Click "Open" and select the `android` folder
   - Wait for Gradle sync to complete

3. **Run on Device/Emulator**
   - Connect an Android device (with USB debugging enabled) OR
   - Create a virtual device (AVD) in Android Studio
   - Click the "Run" button (green triangle)

### Option 2: Using Command Line

1. **Install Android SDK**
   ```bash
   # On Ubuntu/Debian
   sudo apt-get install android-sdk
   ```

2. **Set Environment Variables**
   ```bash
   export ANDROID_HOME=$HOME/Android/Sdk
   export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
   ```

3. **Build APK**
   ```bash
   cd android
   ./gradlew assembleDebug
   ```

4. **Install APK**
   ```bash
   adb install app/build/outputs/apk/debug/app-debug.apk
   ```

## UI Overview

### Main Menu
- **Start Button** (Green): Begin learning current word patch
- **Start with Revision Button** (Orange): Practice revision words
- **Previous/Next Buttons** (Blue): Navigate between patches
- **Test Button** (Purple): Test previous patches
- **Test Revision Button** (Pink): Test and remove mastered revision words
- **Config Button** (Gray): Open configuration
- **Exit Button** (Dark Gray): Close app

### Learning Screen
- Large display of Chinese character or meaning
- Input field for pinyin answer (use numbers 1-4 for tones)
- Color-coded feedback (green = correct, red = incorrect)
- Shows all word details: meaning, hán việt, nghĩa tiếng việt, cách dùng
- Progress bar showing current word position

### Configuration Screen
- HSK Level selector (1-6)
- Words per patch input
- Reset progress button

## Data Storage

- **SharedPreferences**: Stores configuration and progress
  - HSK level
  - Words per patch
  - Current patch index
  - Shuffled word indices

- **Internal Storage**: Stores revision words
  - `revision.txt`: Wrong words from tests

## CSV Format

The app expects CSV files in this format:
```
Chinese,IPA,Pinyin,Meaning_English,Han_Viet,Nghia_Tieng_Viet,Cach_dung_trong_cau
你好,ni xau,nǐ hǎo,hello,nễ hảo,xin chào,你好！(Xin chào!)
```

## Requirements

- **Minimum Android Version**: Android 7.0 (API 24)
- **Target Android Version**: Android 14 (API 34)
- **Permissions**: None required

## Dependencies

- AndroidX AppCompat
- Material Design Components
- ConstraintLayout
- OpenCSV (for CSV parsing)

## Tips for Users

1. **Pinyin Input**: Use numbers 1-4 for tones
   - Example: `ni3hao3` for 你好
   - Spaces are optional: `ni3hao3` or `ni3 hao3`

2. **Endless Mode**: In learning mode, words shuffle and repeat endlessly
   - Press Ctrl+C (or back button) to exit

3. **Revision System**:
   - Wrong test answers → automatically saved to revision
   - Practice revision → use "Start with Revision"
   - Test revision → correct answers removed from revision

4. **Progress Tracking**:
   - Progress is saved automatically
   - Change HSK level → progress resets
   - Use "Reset Progress" to reshuffle and restart

## Building Release APK

```bash
cd android
./gradlew assembleRelease
```

The APK will be at: `app/build/outputs/apk/release/app-release-unsigned.apk`

## Troubleshooting

1. **Build Fails**: Make sure you have the correct Android SDK installed
2. **CSV Not Found**: Ensure CSV files are in `app/src/main/assets/`
3. **App Crashes**: Check Android version meets minimum requirement (API 24+)

## Future Enhancements

- [ ] Audio pronunciation
- [ ] Character stroke order
- [ ] Spaced repetition algorithm
- [ ] Statistics and charts
- [ ] Dark mode
- [ ] Widget support
- [ ] Export/import progress

## License

This app is for educational purposes.

---

**加油！(Jiā yóu!) - Keep learning!**
