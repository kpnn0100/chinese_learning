import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ChineseFlashcardApp());
}

class ChineseFlashcardApp extends StatefulWidget {
  const ChineseFlashcardApp({super.key});

  @override
  State<ChineseFlashcardApp> createState() => _ChineseFlashcardAppState();
}

class _ChineseFlashcardAppState extends State<ChineseFlashcardApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light 
          ? ThemeMode.dark 
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chinese Flashcard',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansTextTheme(),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: HomeScreen(onThemeToggle: toggleTheme),
    );
  }
}
