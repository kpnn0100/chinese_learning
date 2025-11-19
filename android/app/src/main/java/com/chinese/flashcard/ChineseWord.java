package com.chinese.flashcard;

import java.util.HashMap;
import java.util.Map;

public class ChineseWord {
    private String chinese;
    private String pinyin;
    private String meaning;
    private String hanViet;
    private String nghiaTiengViet;
    private String cachDung;
    private String ipa;

    public ChineseWord(String chinese, String pinyin, String meaning, String hanViet, 
                      String nghiaTiengViet, String cachDung, String ipa) {
        this.chinese = chinese;
        this.pinyin = pinyin;
        this.meaning = meaning;
        this.hanViet = hanViet;
        this.nghiaTiengViet = nghiaTiengViet;
        this.cachDung = cachDung;
        this.ipa = ipa;
    }

    // Getters
    public String getChinese() { return chinese; }
    public String getPinyin() { return pinyin; }
    public String getMeaning() { return meaning; }
    public String getHanViet() { return hanViet; }
    public String getNghiaTiengViet() { return nghiaTiengViet; }
    public String getCachDung() { return cachDung; }
    public String getIpa() { return ipa; }

    // Convert to map for saving to revision
    public Map<String, String> toMap() {
        Map<String, String> map = new HashMap<>();
        map.put("chinese", chinese);
        map.put("pinyin", pinyin);
        map.put("meaning", meaning);
        map.put("hanViet", hanViet);
        map.put("nghiaTiengViet", nghiaTiengViet);
        map.put("cachDung", cachDung);
        map.put("ipa", ipa);
        return map;
    }

    // Create from map
    public static ChineseWord fromMap(Map<String, String> map) {
        return new ChineseWord(
            map.getOrDefault("chinese", ""),
            map.getOrDefault("pinyin", ""),
            map.getOrDefault("meaning", ""),
            map.getOrDefault("hanViet", ""),
            map.getOrDefault("nghiaTiengViet", ""),
            map.getOrDefault("cachDung", ""),
            map.getOrDefault("ipa", "")
        );
    }

    // Normalize pinyin for comparison
    public static String normalizePinyin(String pinyin) {
        return pinyin.toLowerCase()
                    .replace(" ", "")
                    .replace(",", "")
                    .replace("ü", "v");
    }

    // Convert tone marks to numbers
    public static String convertToneMarks(String pinyin) {
        return pinyin
            .replace("ā", "a1").replace("á", "a2").replace("ǎ", "a3").replace("à", "a4")
            .replace("ē", "e1").replace("é", "e2").replace("ě", "e3").replace("è", "e4")
            .replace("ī", "i1").replace("í", "i2").replace("ǐ", "i3").replace("ì", "i4")
            .replace("ō", "o1").replace("ó", "o2").replace("ǒ", "o3").replace("ò", "o4")
            .replace("ū", "u1").replace("ú", "u2").replace("ǔ", "u3").replace("ù", "u4")
            .replace("ǖ", "ü1").replace("ǘ", "ü2").replace("ǚ", "ü3").replace("ǜ", "ü4")
            .replace("ü", "v")
            .replace("ń", "n2").replace("ň", "n3").replace("ǹ", "n4");
    }

    // Check if user's pinyin answer is correct
    public boolean checkPinyinAnswer(String userInput) {
        String correctWithNumbers = convertToneMarks(pinyin);
        String userNormalized = normalizePinyin(userInput);
        String correctNormalized = normalizePinyin(correctWithNumbers);
        return userNormalized.equals(correctNormalized);
    }

    // Get display pinyin (with tone numbers)
    public String getDisplayPinyin() {
        return convertToneMarks(pinyin);
    }
}
