import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chinese_word.dart';

class DataService {
  static List<ChineseWord> _words = [];
  static List<int> _shuffledIndices = [];
  static int _currentIndex = 0;
  static int _hskLevel = 1;
  static int _wordsPerPatch = 10;
  static Set<String> _revisionWords = {};

  static Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _hskLevel = prefs.getInt('hsk_level') ?? 1;
    _wordsPerPatch = prefs.getInt('words_per_patch') ?? 10;
    _currentIndex = prefs.getInt('current_index') ?? 0;
    
    final indicesJson = prefs.getString('shuffled_indices');
    if (indicesJson != null) {
      _shuffledIndices = List<int>.from(json.decode(indicesJson));
    }
    
    final revisionJson = prefs.getString('revision_words');
    if (revisionJson != null) {
      _revisionWords = Set<String>.from(json.decode(revisionJson));
    }
  }

  static Future<void> saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hsk_level', _hskLevel);
    await prefs.setInt('words_per_patch', _wordsPerPatch);
    await prefs.setInt('current_index', _currentIndex);
    await prefs.setString('shuffled_indices', json.encode(_shuffledIndices));
    await prefs.setString('revision_words', json.encode(_revisionWords.toList()));
  }

  static Future<void> loadWords() async {
    final String csvString = await rootBundle.loadString(
      'assets/resource/hsk$_hskLevel.csv',
    );
    
    print('DEBUG: CSV String length: ${csvString.length}');
    print('DEBUG: CSV lines count: ${csvString.split('\n').length}');
    
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(
      csvString,
      eol: '\n',
    );
    
    print('DEBUG: CSV table rows (including header): ${csvTable.length}');
    
    // Skip header
    _words = csvTable.skip(1).map((row) {
      try {
        return ChineseWord.fromCsv(row);
      } catch (e) {
        print('ERROR parsing row: $row');
        print('ERROR details: $e');
        rethrow;
      }
    }).toList();
    
    print('DEBUG: Total words loaded: ${_words.length}');
    
    if (_shuffledIndices.isEmpty || _shuffledIndices.length != _words.length) {
      _shuffledIndices = List<int>.generate(_words.length, (i) => i);
      _shuffledIndices.shuffle();
      _currentIndex = 0;
      await saveConfig();
    }
  }

  static List<ChineseWord> getCurrentPatch() {
    final start = _currentIndex * _wordsPerPatch;
    final end = (start + _wordsPerPatch).clamp(0, _shuffledIndices.length);
    
    if (start >= _shuffledIndices.length) return [];
    
    return _shuffledIndices
        .sublist(start, end)
        .map((i) => _words[i])
        .toList();
  }

  static Future<void> nextPatch() async {
    final totalPatches = (_words.length / _wordsPerPatch).ceil();
    if (_currentIndex < totalPatches - 1) {
      _currentIndex++;
      await saveConfig();
    }
  }

  static Future<void> previousPatch() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await saveConfig();
    }
  }

  static List<ChineseWord> getPreviousPatch([int patchesBack = 1]) {
    if (_currentIndex < patchesBack) return [];
    
    List<ChineseWord> allWords = [];
    for (int i = 1; i <= patchesBack; i++) {
      final patchIndex = _currentIndex - i;
      final start = patchIndex * _wordsPerPatch;
      final end = (start + _wordsPerPatch).clamp(0, _shuffledIndices.length);
      
      if (start < _shuffledIndices.length) {
        final patchWords = _shuffledIndices
            .sublist(start, end)
            .map((i) => _words[i])
            .toList();
        allWords.addAll(patchWords);
      }
    }
    
    return allWords;
  }

  static int get currentPatch => _currentIndex + 1;
  static int get totalPatches => (_words.length / _wordsPerPatch).ceil();
  static int get hskLevel => _hskLevel;
  static int get wordsPerPatch => _wordsPerPatch;
  static int get totalWords => _words.length;

  static Future<void> setHskLevel(int level) async {
    _hskLevel = level;
    _currentIndex = 0;
    _shuffledIndices.clear();
    await saveConfig();
    await loadWords();
  }

  static Future<void> setWordsPerPatch(int words) async {
    _wordsPerPatch = words;
    await saveConfig();
  }

  static Future<void> resetProgress() async {
    _shuffledIndices = List<int>.generate(_words.length, (i) => i);
    _shuffledIndices.shuffle();
    _currentIndex = 0;
    await saveConfig();
  }

  // Revision system methods
  static Future<void> addToRevision(String chinese) async {
    _revisionWords.add(chinese);
    await saveConfig();
  }

  static Future<void> removeFromRevision(String chinese) async {
    _revisionWords.remove(chinese);
    await saveConfig();
  }

  static List<ChineseWord> getRevisionWords() {
    return _words.where((word) => _revisionWords.contains(word.chinese)).toList();
  }

  static int get revisionCount => _revisionWords.length;

  static Future<void> clearRevision() async {
    _revisionWords.clear();
    await saveConfig();
  }
}
