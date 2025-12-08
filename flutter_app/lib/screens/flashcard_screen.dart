import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flip_card/flip_card.dart';
import '../models/chinese_word.dart';

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
  int _currentIndex = 0;
  bool _showAnswer = false;
  final TextEditingController _answerController = TextEditingController();
  bool? _isCorrect;
  int _correctCount = 0;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _answerController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  ChineseWord get _currentWord => widget.words[_currentIndex];

  void _checkAnswer() {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an answer')),
      );
      return;
    }

    final userAnswer = _answerController.text.trim().toLowerCase();
    final correctAnswer = _currentWord.pinyin.toLowerCase();
    
    setState(() {
      _isCorrect = _checkPinyin(userAnswer, correctAnswer);
      _showAnswer = true;
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
        .replaceAll('ü', 'v');
    
    final userNormalized = user
        .replaceAll(' ', '')
        .replaceAll(',', '')
        .replaceAll('ü', 'v');
    
    return userNormalized == normalized;
  }

  void _nextWord() {
    if (_currentIndex < widget.words.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
        _isCorrect = null;
        _answerController.clear();
      });
      
      _slideController.reset();
      _slideController.forward();
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final score = (_correctCount / widget.words.length * 100).toStringAsFixed(1);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.amber, size: 32),
            const SizedBox(width: 12),
            const Text('Complete!'),
          ],
        ).animate().scale(duration: 500.ms),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $_correctCount/${widget.words.length}',
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
        title: Text(widget.isTest ? 'Test' : 'Learn'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.purple.shade400],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
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
    final progress = (_currentIndex + 1) / widget.words.length;
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentIndex + 1}/${widget.words.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                'Score: $_correctCount',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.7
                    ? Colors.green
                    : progress > 0.4
                        ? Colors.orange
                        : Colors.blue,
              ),
            ),
          ).animate().scaleX(duration: 800.ms, curve: Curves.easeOut),
        ],
      ),
    );
  }

  Widget _buildQuestionView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 15,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.blue.shade50],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chinese:',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey.shade600,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.2, end: 0),
                const SizedBox(height: 20),
                Text(
                  _currentWord.chinese,
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1))
                    .shimmer(duration: 2000.ms, delay: 800.ms),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Type the pinyin (use 1234 for tones)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 15,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isCorrect == true
                    ? [Colors.green.shade50, Colors.green.shade100]
                    : [Colors.red.shade50, Colors.red.shade100],
              ),
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
                    _currentWord.chinese,
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
                    _currentWord.pinyin,
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
                    _currentWord.meaningEnglish,
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
                  
                  if (_currentWord.hanViet.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Hán Việt: ${_currentWord.hanViet}',
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
                  
                  if (_currentWord.nghiaTiengViet.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      _currentWord.nghiaTiengViet,
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_showAnswer) ...[
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText: 'Enter pinyin...',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              style: const TextStyle(fontSize: 18),
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
                elevation: 5,
              ),
              child: const Text(
                'Submit',
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
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              child: Text(
                _currentIndex < widget.words.length - 1 ? 'Next ➡️' : 'Finish',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
