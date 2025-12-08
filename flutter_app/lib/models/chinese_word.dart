class ChineseWord {
  final String chinese;
  final String pinyin;
  final String meaningEnglish;
  final String hanViet;
  final String nghiaTiengViet;
  final String cachDung;

  ChineseWord({
    required this.chinese,
    required this.pinyin,
    required this.meaningEnglish,
    required this.hanViet,
    required this.nghiaTiengViet,
    required this.cachDung,
  });

  factory ChineseWord.fromCsv(List<dynamic> row) {
    return ChineseWord(
      chinese: row[0].toString(),
      pinyin: row[1].toString(),
      meaningEnglish: row[2].toString(),
      hanViet: row.length > 3 ? row[3].toString() : '',
      nghiaTiengViet: row.length > 4 ? row[4].toString() : '',
      cachDung: row.length > 5 ? row[5].toString() : '',
    );
  }
}
