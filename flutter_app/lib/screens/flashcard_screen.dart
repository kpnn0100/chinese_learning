import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../models/chinese_word.dart';
import '../services/data_service.dart';
import '../localization/app_strings.dart';

class FlashcardScreen extends StatefulWidget {
  final List<ChineseWord> words;
  final bool isTest;
  final bool isRevision;

  const FlashcardScreen({
    super.key,
    required this.words,
    required this.isTest,
    required this.isRevision,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with TickerProviderStateMixin {
  bool _showAnswer = false;
  final TextEditingController _answerController = TextEditingController();
  bool? _isCorrect;
  int _correctCount = 0;
  int _totalAttempts = 0;
  int _currentIndex = 0;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late List<ChineseWord> _testWords;
  late List<ChineseWord> _wordPool; // For infinite learning mode
  ChineseWord? _currentWord;
  bool _showChinese = true; // Randomly show Chinese or meaning
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    if (widget.isTest) {
      // Test mode: Use all provided words in random order
      final shuffled = List<ChineseWord>.from(widget.words)..shuffle(_random);
      _testWords = shuffled;
      
      if (_testWords.isNotEmpty) {
        _currentWord = _testWords[_currentIndex];
      }
    } else {
      // Learning mode: Infinite random words from patches
      _wordPool = List.from(widget.words);
      _testWords = []; // Not used in learning mode
      _pickRandomWord();
    }
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
  }
  
  void _pickRandomWord() {
    if (_wordPool.isEmpty) return;
    
    // Pick random word from pool
    final randomIndex = _random.nextInt(_wordPool.length);
    _currentWord = _wordPool[randomIndex];
    
    // Randomly decide to show Chinese or meaning
    _showChinese = _random.nextBool();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _checkAnswer() async {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.pleaseEnterAnswer)),
      );
      return;
    }
    
    if (_currentWord == null) return;

    final userAnswer = _answerController.text.trim().toLowerCase();
    final correctAnswer = _currentWord!.pinyin.toLowerCase();
    
    final isCorrect = _checkPinyin(userAnswer, correctAnswer);
    
    // Add to revision if wrong and in test mode
    if (!isCorrect && widget.isTest) {
      await DataService.addToRevision(_currentWord!.chinese);
    }
    
    // Remove from revision if correct and in revision test mode
    if (isCorrect && widget.isRevision) {
      await DataService.removeFromRevision(_currentWord!.chinese);
    }
    
    setState(() {
      _isCorrect = isCorrect;
      _showAnswer = true;
      _totalAttempts++;
      if (_isCorrect!) _correctCount++;
    });
  }

  bool _checkPinyin(String user, String correct) {
    // Normalize both strings
    final normalized = correct
        .replaceAll(' ', '')
        .replaceAll(',', '')
        .replaceAll('ā', 'a1').replaceAll('á', 'a2')
        .replaceAll('ǎ', 'a3').replaceAll('à', 'a4')
        .replaceAll('ē', 'e1').replaceAll('é', 'e2')
        .replaceAll('ě', 'e3').replaceAll('è', 'e4')
        .replaceAll('ī', 'i1').replaceAll('í', 'i2')
        .replaceAll('ǐ', 'i3').replaceAll('ì', 'i4')
        .replaceAll('ō', 'o1').replaceAll('ó', 'o2')
        .replaceAll('ǒ', 'o3').replaceAll('ò', 'o4')
        .replaceAll('ū', 'u1').replaceAll('ú', 'u2')
        .replaceAll('ǔ', 'u3').replaceAll('ù', 'u4')
        .replaceAll('ü', 'v')
        .replaceAll('ǖ', 'v1').replaceAll('ǘ', 'v2').replaceAll('ǚ', 'v3').replaceAll('ǜ', 'v4');
          
          final userNormalized = user
        .replaceAll(' ', '')
        .replaceAll(',', '')
        .replaceAll('ü', 'v');
    
    return userNormalized == normalized;
  }

  void _nextWord() {
    if (widget.isTest) {
      // Test mode: Move to next word in fixed list
      _currentIndex++;
      
      // Check if we've completed all words
      if (_currentIndex >= _testWords.length) {
        _showResults();
        return;
      }
      
      setState(() {
        _currentWord = _testWords[_currentIndex];
        _showAnswer = false;
        _isCorrect = null;
        _answerController.clear();
      });
    } else {
      // Learning mode: Pick random word infinitely
      setState(() {
        _pickRandomWord();
        _showAnswer = false;
        _isCorrect = null;
        _answerController.clear();
      });
    }
    
    _slideController.reset();
    _slideController.forward();
  }

  void _showResults() {
    final score = (_correctCount / _testWords.length * 100).toStringAsFixed(1);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.amber, size: 32),
            const SizedBox(width: 12),
            const Text(AppStrings.complete),
          ],
        ).animate().scale(duration: 500.ms),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${AppStrings.score}: $_correctCount/${_testWords.length}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '($score%)',
              style: TextStyle(fontSize: 20, color: Colors.grey.shade600),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isTest ? AppStrings.test : AppStrings.learn),
        elevation: 0,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator()
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.2, end: 0),
              
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _showAnswer ? _buildAnswerView() : _buildQuestionView(),
                ),
              ),
              
              // Input and buttons
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final scorePercentage = _totalAttempts > 0 
        ? (_correctCount / _totalAttempts * 100).toStringAsFixed(0)
        : '0';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.isTest)
                Text(
                  'Progress: ${_currentIndex + 1}/${_testWords.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              Text(
                'Score: $_correctCount/$_totalAttempts ($scorePercentage%)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          if (widget.isTest) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _testWords.isNotEmpty 
                  ? (_currentIndex + 1) / _testWords.length 
                  : 0.0,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionView() {
    if (_currentWord == null) return const SizedBox.shrink();
    
    // Determine what to display: Chinese or Meaning
    final displayText = (widget.isTest || _showChinese) 
        ? _currentWord!.chinese 
        : _currentWord!.meaningEnglish;
    final displayLabel = (widget.isTest || _showChinese) 
        ? 'Chinese' 
        : 'Meaning';
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!widget.isTest && !_showChinese)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      displayLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                  ),
                Text(
                  displayText,
                  style: TextStyle(
                    fontSize: _showChinese ? 64 : 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1))
                    .shimmer(duration: 2000.ms, delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerView() {
    if (_currentWord == null) return const SizedBox.shrink();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
              color: _isCorrect == true ? Colors.green : Colors.red,
              width: 2,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: _isCorrect == true
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Result indicator
                  Icon(
                    _isCorrect == true ? Icons.check_circle : Icons.cancel,
                    size: 60,
                    color: _isCorrect == true ? Colors.green : Colors.red,
                  )
                      .animate()
                      .scale(
                        duration: 500.ms,
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                      )
                      .shake(duration: 500.ms),
                  const SizedBox(height: 20),
                  
                  // Chinese
                  Text(
                    _currentWord!.chinese,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange.shade700,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 12),
                  
                  // Pinyin
                  Text(
                    _currentWord!.pinyin,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 300.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 12),
                  
                  // English
                  Text(
                    _currentWord!.meaningEnglish,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms)
                      .slideY(begin: 0.2, end: 0),
                  
                  if (_currentWord!.hanViet.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${AppStrings.hanViet} ${_currentWord!.hanViet}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.purple,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 500.ms)
                        .slideY(begin: 0.2, end: 0),
                  ],
                  
                  if (_currentWord!.nghiaTiengViet.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      _currentWord!.nghiaTiengViet,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_showAnswer) ...[
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText: 'pinyin (1234 for tones)',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              onSubmitted: (_) => _checkAnswer(),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                AppStrings.submit,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 100.ms)
                .slideY(begin: 0.3, end: 0)
                .shimmer(duration: 2000.ms, delay: 600.ms),
          ] else ...[
            ElevatedButton(
              onPressed: _nextWord,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                AppStrings.next,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale()
                .shimmer(duration: 1500.ms, delay: 300.ms),
          ],
        ],
      ),
    );
  }
}
