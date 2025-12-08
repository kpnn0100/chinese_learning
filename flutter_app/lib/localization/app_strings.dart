class AppStrings {
  // Home Screen
  static const String appTitle = 'Chinese Flashcard';
  static const String hskLevel = 'HSK';
  static const String patch = 'Patch';
  static const String words = 'Words';
  static const String startLearning = 'Start Learning';
  static const String startLearningSubtitle = 'Begin current patch';
  static const String practiceOldLesson = 'Practice Old Lesson';
  static const String practiceOldLessonSubtitle = 'Review previous patches (mistakes → revision)';
  static const String startRevision = 'Start Revision';
  static const String startRevisionSubtitle = 'Practice words you got wrong';
  static const String testRevision = 'Test Revision';
  static const String testRevisionSubtitle = 'Test revision (pass → remove from list)';
  static const String previousPatch = 'Previous';
  static const String nextPatch = 'Next';
  static const String settings = 'Settings';
  
  // Practice Old Lesson Dialog
  static const String practiceOldLessonsTitle = 'Practice Old Lessons';
  static const String currentPatch = 'Current: Patch';
  static const String patchSingular = 'patch';
  static const String patchPlural = 'patches';
  static const String cancel = 'Cancel';
  static const String start = 'Start';
  
  // Flashcard Screen
  static const String learn = 'Learn';
  static const String test = 'Test';
  static const String question = 'Question';
  static const String score = 'Score';
  static const String chinese = 'Chinese:';
  static const String typePinyinHint = 'Type the pinyin (use 1234 for tones)';
  static const String pinyin = 'Pinyin:';
  static const String english = 'English:';
  static const String hanViet = 'Hán Việt:';
  static const String vietnamese = 'Nghĩa Tiếng Việt:';
  static const String example = 'Example:';
  static const String submit = 'Submit';
  static const String next = 'Next ➡️';
  static const String finish = 'Finish';
  static const String complete = 'Complete!';
  static const String pleaseEnterAnswer = 'Please enter an answer';
  
  // Config Screen
  static const String configuration = 'Configuration';
  static const String hskLevelTitle = 'HSK Level';
  static const String hskLevelSubtitle = 'Select your HSK level (1-6)';
  static const String wordsPerPatchTitle = 'Words Per Patch';
  static const String wordsPerPatchSubtitle = 'Number of words in each learning patch';
  static const String resetProgressTitle = 'Reset Progress';
  static const String resetProgressSubtitle = 'Reshuffle all words and start from the beginning';
  static const String resetProgress = 'Reset Progress';
  static const String saveConfiguration = 'Save Configuration';
  static const String confirmReset = 'Confirm Reset';
  static const String confirmResetMessage = 'Are you sure you want to reset progress? This will reshuffle all words and start from the beginning.';
  static const String reset = 'Reset';
  static const String progressReset = 'Progress has been reset!';
  static const String hskLevelChanged = 'HSK level changed. Progress has been reset.';
  static const String configSaved = 'Configuration saved!';
  
  // Messages
  static const String noWordsAvailable = 'No words available!';
  static const String noPreviousLessons = 'No previous lessons available';
  static const String noWordsInPatches = 'No words found in selected patches';
  static const String noRevisionWords = 'No revision words! Practice to add some.';
  static const String movedToPatch = 'Moved to patch';
  
  // Debug
  static const String debugCsvLength = 'DEBUG: CSV String length:';
  static const String debugCsvLines = 'DEBUG: CSV lines count:';
  static const String debugCsvRows = 'DEBUG: CSV table rows (including header):';
  static const String debugTotalWords = 'DEBUG: Total words loaded:';
  static const String errorParsingRow = 'ERROR parsing row:';
  static const String errorDetails = 'ERROR details:';
}
