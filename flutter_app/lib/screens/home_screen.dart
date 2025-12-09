import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/data_service.dart';
import '../localization/app_strings.dart';
import 'flashcard_screen.dart';
import 'config_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  
  const HomeScreen({super.key, required this.onThemeToggle});

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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chinese Flashcard',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.2, end: 0),
                  Text(
                    '学习中文',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          height: 2.0, // Increased line height to prevent bottom cropping
                        ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: widget.onThemeToggle,
                  tooltip: 'Toggle theme',
                ).animate().scale(duration: 400.ms, delay: 400.ms),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats Card
                  _buildStatsCard(context)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms)
                      .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 32),

                  // Primary Actions
                  _buildActionCard(
                    context,
                    icon: Icons.school,
                    title: AppStrings.startLearning,
                    subtitle: AppStrings.startLearningSubtitle,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => _startLearning(false),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 400.ms)
                      .slideX(begin: -0.1, end: 0),

                  const SizedBox(height: 12),

                  _buildActionCard(
                    context,
                    icon: Icons.quiz,
                    title: AppStrings.practiceOldLesson,
                    subtitle: AppStrings.practiceOldLessonSubtitle,
                    color: Colors.blue,
                    onTap: _practiceOldLesson,
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 450.ms)
                      .slideX(begin: -0.1, end: 0),

                  const SizedBox(height: 12),

                  _buildActionCard(
                    context,
                    icon: Icons.history_edu,
                    title: AppStrings.startRevision,
                    subtitle: 'Learn from mistakes (${DataService.revisionCount} words)',
                    color: Colors.orange,
                    onTap: () => _startRevisionLearn(),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 500.ms)
                      .slideX(begin: -0.1, end: 0),

                  const SizedBox(height: 12),

                  _buildActionCard(
                    context,
                    icon: Icons.task_alt,
                    title: AppStrings.testRevision,
                    subtitle: 'Clear words you\'ve mastered',
                    color: Colors.green,
                    onTap: () => _startRevisionTest(),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 550.ms)
                      .slideX(begin: -0.1, end: 0),

                  const SizedBox(height: 32),

                  // Navigation
                  Text(
                    'Navigation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 600.ms),
                  
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildIconButton(
                          context,
                          icon: Icons.arrow_back,
                          label: AppStrings.previousPatch,
                          onTap: _previousPatch,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 700.ms)
                            .scale(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildIconButton(
                          context,
                          icon: Icons.arrow_forward,
                          label: AppStrings.nextPatch,
                          onTap: _nextPatch,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 750.ms)
                            .scale(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Settings
                  Text(
                    'More',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 800.ms),
                  
                  const SizedBox(height: 12),

                  _buildSimpleButton(
                    context,
                    icon: Icons.settings_outlined,
                    label: AppStrings.settings,
                    onTap: _openConfig,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 850.ms)
                      .slideX(begin: 0.1, end: 0),

                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  label: AppStrings.hskLevel,
                  value: '${DataService.hskLevel}',
                ),
                _buildStatItem(
                  context,
                  label: AppStrings.patch,
                  value: '${DataService.currentPatch}/${DataService.totalPatches}',
                ),
                _buildStatItem(
                  context,
                  label: AppStrings.words,
                  value: '${DataService.totalWords}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
        title: Text(label),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _startLearning(bool isRevision) {
    final words = DataService.getCurrentPatch();
    if (words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.noWordsAvailable)),
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

  void _startTest(bool isRevision) {
    final words = DataService.getCurrentPatch();
    if (words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.noWordsAvailable)),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardScreen(
          words: words,
          isTest: true,
          isRevision: isRevision,
        ),
      ),
    ).then((_) => setState(() {}));
  }



  void _startRevisionLearn() {
    final words = DataService.getRevisionWords();
    if (words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No revision words! Practice to add some.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardScreen(
          words: words,
          isTest: false,
          isRevision: false,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _startRevisionTest() {
    final words = DataService.getRevisionWords();
    if (words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No revision words! Practice to add some.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardScreen(
          words: words,
          isTest: true,
          isRevision: true,
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

  Future<void> _practiceOldLesson() async {
    final currentPatch = DataService.currentPatch;
    
    if (currentPatch <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No previous lessons available')),
      );
      return;
    }
    
    final maxPatches = currentPatch - 1;
    int selectedPatches = 1;
    
    // Show dialog with slider to select number of patches
    final patchCount = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Practice Old Lessons'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Current: Patch ${DataService.currentPatch}/${DataService.totalPatches}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        selectedPatches == 1 ? '1 patch' : '$selectedPatches patches',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${selectedPatches * DataService.wordsPerPatch} words',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Slider(
                value: selectedPatches.toDouble(),
                min: 1,
                max: maxPatches.toDouble(),
                divisions: maxPatches > 1 ? maxPatches - 1 : 1,
                label: '$selectedPatches',
                onChanged: (value) {
                  setState(() {
                    selectedPatches = value.toInt();
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '$maxPatches',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, selectedPatches),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
            ),
          ],
        ),
      ),
    );
    
    if (patchCount == null || !mounted) return;
    
    final oldWords = DataService.getPreviousPatch(patchCount);
    
    if (oldWords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No words found in selected patches')),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardScreen(
          words: oldWords,
          isTest: true,
          isRevision: false,
        ),
      ),
    ).then((_) => setState(() {}));
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
