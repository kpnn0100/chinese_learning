import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/data_service.dart';
import 'flashcard_screen.dart';
import 'config_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await DataService.loadConfig();
    await DataService.loadWords();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Title
                Text(
                  'Chinese Flashcard',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.3, end: 0),
                const SizedBox(height: 8),
                Text(
                  '学习中文',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: -0.3, end: 0),
                const SizedBox(height: 30),

                // Info Card
                _buildInfoCard().animate().fadeIn(duration: 600.ms, delay: 400.ms).scale(),

                const SizedBox(height: 30),

                // Learning Section
                _buildSectionTitle('Learning', Icons.school)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 600.ms)
                    .slideX(begin: -0.2, end: 0),
                const SizedBox(height: 15),
                _buildMenuButton(
                  '📚 Start - Learn Current Patch',
                  Colors.green,
                  () => _startLearning(false),
                  0,
                ),
                const SizedBox(height: 12),
                _buildMenuButton(
                  '🔄 Start with Revision',
                  Colors.orange,
                  () => _startLearning(true),
                  1,
                ),

                const SizedBox(height: 30),

                // Navigation Section
                _buildSectionTitle('Navigation', Icons.navigation)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 800.ms)
                    .slideX(begin: -0.2, end: 0),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildMenuButton(
                        '⬅️ Previous',
                        Colors.blue,
                        _previousPatch,
                        2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMenuButton(
                        'Next ➡️',
                        Colors.blue,
                        _nextPatch,
                        3,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Testing Section
                _buildSectionTitle('Testing', Icons.quiz)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 1000.ms)
                    .slideX(begin: -0.2, end: 0),
                const SizedBox(height: 15),
                _buildMenuButton(
                  '✏️ Test Previous Patches',
                  Colors.purple,
                  () {},
                  4,
                ),
                const SizedBox(height: 12),
                _buildMenuButton(
                  '✅ Test Revision',
                  Colors.pink,
                  () {},
                  5,
                ),

                const SizedBox(height: 30),

                // Settings Section
                _buildSectionTitle('Settings', Icons.settings)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 1200.ms)
                    .slideX(begin: -0.2, end: 0),
                const SizedBox(height: 15),
                _buildMenuButton(
                  '⚙️ Configuration',
                  Colors.blueGrey,
                  _openConfig,
                  6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
          ),
        ),
        child: Column(
          children: [
            _buildInfoRow('HSK Level', '${DataService.hskLevel}'),
            const Divider(),
            _buildInfoRow('Words per patch', '${DataService.wordsPerPatch}'),
            const Divider(),
            _buildInfoRow(
              'Current Patch',
              '${DataService.currentPatch}/${DataService.totalPatches}',
            ),
            const Divider(),
            _buildInfoRow('Total Words', '${DataService.totalWords}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton(
    String text,
    Color color,
    VoidCallback onPressed,
    int index,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: (700 + index * 100).ms)
        .slideX(begin: 0.3, end: 0)
        .shimmer(duration: 2000.ms, delay: (1000 + index * 200).ms);
  }

  void _startLearning(bool isRevision) {
    final words = DataService.getCurrentPatch();
    if (words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No words available!')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardScreen(
          words: words,
          isTest: false,
          isRevision: isRevision,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  Future<void> _nextPatch() async {
    await DataService.nextPatch();
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Moved to patch ${DataService.currentPatch}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _previousPatch() async {
    await DataService.previousPatch();
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Moved to patch ${DataService.currentPatch}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openConfig() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConfigScreen()),
    ).then((_) => _loadData());
  }
}
