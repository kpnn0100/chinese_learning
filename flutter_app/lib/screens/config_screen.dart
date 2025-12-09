import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/data_service.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  int _hskLevel = 1;
  int _wordsPerPatch = 10;

  @override
  void initState() {
    super.initState();
    _hskLevel = DataService.hskLevel;
    _wordsPerPatch = DataService.wordsPerPatch;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
        elevation: 0,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // HSK Level
            _buildSettingCard(
              title: 'HSK Level',
              subtitle: 'Select your HSK level (1-6)',
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left Arrow
                    IconButton(
                      onPressed: _hskLevel > 1
                          ? () {
                              setState(() => _hskLevel--);
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      iconSize: 48,
                      color: _hskLevel > 1
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                    )
                        .animate(key: ValueKey('left_$_hskLevel'))
                        .scale(duration: 200.ms)
                        .then()
                        .shake(duration: 300.ms),
                    
                    const SizedBox(width: 20),
                    
                    // HSK Level Display
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: RotationTransition(
                            turns: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        key: ValueKey<int>(_hskLevel),
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'HSK',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            Text(
                              '$_hskLevel',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 20),
                    
                    // Right Arrow
                    IconButton(
                      onPressed: _hskLevel < 6
                          ? () {
                              setState(() => _hskLevel++);
                            }
                          : null,
                      icon: const Icon(Icons.chevron_right),
                      iconSize: 48,
                      color: _hskLevel < 6
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                    )
                        .animate(key: ValueKey('right_$_hskLevel'))
                        .scale(duration: 200.ms)
                        .then()
                        .shake(duration: 300.ms),
                  ],
                ),
              ),
              index: 0,
            ),

            const SizedBox(height: 20),

            // Words per patch
            _buildSettingCard(
              title: 'Words Per Patch',
              subtitle: 'Number of words in each learning patch',
              child: Column(
                children: [
                  Slider(
                    value: _wordsPerPatch.toDouble(),
                    min: 5,
                    max: 30,
                    divisions: 25,
                    label: _wordsPerPatch.toString(),
                    onChanged: (value) {
                      setState(() => _wordsPerPatch = value.toInt());
                    },
                  ),
                  Text(
                    '$_wordsPerPatch words',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              index: 1,
            ),

            const SizedBox(height: 20),

            // Reset progress
            _buildSettingCard(
              title: 'Reset Progress',
              subtitle: 'Reshuffle all words and start from the beginning',
              child: ElevatedButton.icon(
                onPressed: _resetProgress,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Progress'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 30,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              index: 2,
            ),

            const SizedBox(height: 30),

            // Save button
            ElevatedButton.icon(
              onPressed: _saveConfig,
              icon: const Icon(Icons.save),
              label: const Text(
                'Save Configuration',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .scale()
                .shimmer(duration: 2000.ms, delay: 1000.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required Widget child,
    required int index,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: (index * 150).ms)
        .slideX(begin: 0.2, end: 0);
  }

  Future<void> _resetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Confirm Reset'),
        content: const Text(
          'Are you sure you want to reset progress? This will reshuffle all words and start from the beginning.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await DataService.resetProgress();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progress has been reset!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _saveConfig() async {
    final oldLevel = DataService.hskLevel;
    
    await DataService.setWordsPerPatch(_wordsPerPatch);
    
    if (_hskLevel != oldLevel) {
      await DataService.setHskLevel(_hskLevel);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('HSK level changed. Progress has been reset.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration saved!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
