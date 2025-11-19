package com.chinese.flashcard;

import android.content.Context;
import android.content.SharedPreferences;

import com.opencsv.CSVReader;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class FlashcardManager {
    private static final String PREFS_NAME = "ChineseFlashcardPrefs";
    private static final String KEY_HSK_LEVEL = "hsk_level";
    private static final String KEY_WORDS_PER_PATCH = "words_per_patch";
    private static final String KEY_CURRENT_INDEX = "current_index";
    private static final String KEY_SHUFFLED_INDICES = "shuffled_indices";
    private static final String REVISION_FILE = "revision.txt";

    private Context context;
    private SharedPreferences prefs;
    private List<ChineseWord> allWords;
    private List<Integer> shuffledIndices;
    private int currentIndex;
    private int hskLevel;
    private int wordsPerPatch;

    public FlashcardManager(Context context) {
        this.context = context;
        this.prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        loadConfig();
        loadWords();
        loadProgress();
    }

    private void loadConfig() {
        hskLevel = prefs.getInt(KEY_HSK_LEVEL, 1);
        wordsPerPatch = prefs.getInt(KEY_WORDS_PER_PATCH, 10);
    }

    public void saveConfig() {
        prefs.edit()
            .putInt(KEY_HSK_LEVEL, hskLevel)
            .putInt(KEY_WORDS_PER_PATCH, wordsPerPatch)
            .apply();
    }

    private void loadProgress() {
        currentIndex = prefs.getInt(KEY_CURRENT_INDEX, 0);
        String indicesStr = prefs.getString(KEY_SHUFFLED_INDICES, "");
        
        shuffledIndices = new ArrayList<>();
        if (!indicesStr.isEmpty()) {
            String[] parts = indicesStr.split(",");
            for (String part : parts) {
                shuffledIndices.add(Integer.parseInt(part));
            }
        }
        
        // Initialize if empty or word count changed
        if (shuffledIndices.isEmpty() || shuffledIndices.size() != allWords.size()) {
            resetProgress();
        }
    }

    public void saveProgress() {
        StringBuilder indicesStr = new StringBuilder();
        for (int i = 0; i < shuffledIndices.size(); i++) {
            if (i > 0) indicesStr.append(",");
            indicesStr.append(shuffledIndices.get(i));
        }
        
        prefs.edit()
            .putInt(KEY_CURRENT_INDEX, currentIndex)
            .putString(KEY_SHUFFLED_INDICES, indicesStr.toString())
            .apply();
    }

    public void resetProgress() {
        shuffledIndices = new ArrayList<>();
        for (int i = 0; i < allWords.size(); i++) {
            shuffledIndices.add(i);
        }
        Collections.shuffle(shuffledIndices);
        currentIndex = 0;
        saveProgress();
    }

    private void loadWords() {
        allWords = new ArrayList<>();
        String fileName = "hsk" + hskLevel + ".csv";
        
        try {
            InputStreamReader isr = new InputStreamReader(context.getAssets().open(fileName));
            CSVReader reader = new CSVReader(isr);
            
            String[] header = reader.readNext(); // Skip header
            String[] line;
            
            while ((line = reader.readNext()) != null) {
                if (line.length >= 3) {
                    ChineseWord word = new ChineseWord(
                        line[0], // Chinese
                        line[1], // Pinyin
                        line[2], // Meaning_English
                        line.length > 3 ? line[3] : "", // Han_Viet
                        line.length > 4 ? line[4] : "", // Nghia_Tieng_Viet
                        line.length > 5 ? line[5] : "", // Cach_dung
                        ""  // IPA (not in CSV)
                    );
                    allWords.add(word);
                }
            }
            reader.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<ChineseWord> getCurrentPatch() {
        List<ChineseWord> patch = new ArrayList<>();
        int start = currentIndex * wordsPerPatch;
        int end = Math.min(start + wordsPerPatch, shuffledIndices.size());
        
        if (start < shuffledIndices.size()) {
            for (int i = start; i < end; i++) {
                patch.add(allWords.get(shuffledIndices.get(i)));
            }
        }
        
        return patch;
    }

    public boolean canMoveNext() {
        int totalPatches = (allWords.size() + wordsPerPatch - 1) / wordsPerPatch;
        return currentIndex < totalPatches - 1;
    }

    public boolean canMovePrevious() {
        return currentIndex > 0;
    }

    public void moveNext() {
        if (canMoveNext()) {
            currentIndex++;
            saveProgress();
        }
    }

    public void movePrevious() {
        if (canMovePrevious()) {
            currentIndex--;
            saveProgress();
        }
    }

    public List<ChineseWord> getTestWords(int numPatches) {
        List<ChineseWord> testWords = new ArrayList<>();
        int maxPatches = Math.min(numPatches, currentIndex);
        int start = (currentIndex - maxPatches) * wordsPerPatch;
        int end = currentIndex * wordsPerPatch;
        
        for (int i = start; i < end && i < shuffledIndices.size(); i++) {
            testWords.add(allWords.get(shuffledIndices.get(i)));
        }
        
        Collections.shuffle(testWords);
        return testWords;
    }

    // Revision methods
    public void saveWordToRevision(ChineseWord word) {
        File file = new File(context.getFilesDir(), REVISION_FILE);
        
        // Check if word already exists
        Set<String> existingWords = new HashSet<>();
        if (file.exists()) {
            try {
                BufferedReader reader = new BufferedReader(new FileReader(file));
                String line;
                while ((line = reader.readLine()) != null) {
                    String[] parts = line.split("\\|");
                    if (parts.length > 0) {
                        existingWords.add(parts[0]);
                    }
                }
                reader.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        
        // Only add if not already in revision
        if (!existingWords.contains(word.getChinese())) {
            try {
                BufferedWriter writer = new BufferedWriter(new FileWriter(file, true));
                writer.write(String.format("%s|%s|%s|%s|%s|%s|%s\n",
                    word.getChinese(),
                    word.getPinyin(),
                    word.getMeaning(),
                    word.getHanViet(),
                    word.getNghiaTiengViet(),
                    word.getCachDung(),
                    word.getIpa()
                ));
                writer.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public List<ChineseWord> loadRevisionWords() {
        List<ChineseWord> revisionWords = new ArrayList<>();
        File file = new File(context.getFilesDir(), REVISION_FILE);
        
        if (!file.exists()) {
            return revisionWords;
        }
        
        try {
            BufferedReader reader = new BufferedReader(new FileReader(file));
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\|");
                if (parts.length >= 3) {
                    ChineseWord word = new ChineseWord(
                        parts[0], // Chinese
                        parts[1], // Pinyin
                        parts[2], // Meaning
                        parts.length > 3 ? parts[3] : "", // Han_Viet
                        parts.length > 4 ? parts[4] : "", // Nghia_Tieng_Viet
                        parts.length > 5 ? parts[5] : "", // Cach_dung
                        parts.length > 6 ? parts[6] : ""  // IPA
                    );
                    revisionWords.add(word);
                }
            }
            reader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        
        return revisionWords;
    }

    public void removeWordFromRevision(ChineseWord word) {
        File file = new File(context.getFilesDir(), REVISION_FILE);
        
        if (!file.exists()) {
            return;
        }
        
        List<String> remainingLines = new ArrayList<>();
        try {
            BufferedReader reader = new BufferedReader(new FileReader(file));
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\|");
                if (parts.length > 0 && !parts[0].equals(word.getChinese())) {
                    remainingLines.add(line);
                }
            }
            reader.close();
            
            // Write back remaining words
            BufferedWriter writer = new BufferedWriter(new FileWriter(file));
            for (String remainingLine : remainingLines) {
                writer.write(remainingLine + "\n");
            }
            writer.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public int getRevisionCount() {
        return loadRevisionWords().size();
    }

    // Getters and setters
    public int getHskLevel() { return hskLevel; }
    public void setHskLevel(int level) {
        if (level != hskLevel) {
            hskLevel = level;
            loadWords();
            resetProgress();
            saveConfig();
        }
    }

    public int getWordsPerPatch() { return wordsPerPatch; }
    public void setWordsPerPatch(int words) {
        wordsPerPatch = words;
        saveConfig();
    }

    public int getCurrentIndex() { return currentIndex; }
    public int getTotalPatches() { 
        return (allWords.size() + wordsPerPatch - 1) / wordsPerPatch;
    }
    public int getTotalWords() { return allWords.size(); }
}
