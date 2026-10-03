class Language {
  int id;
  String name;
  String code;
  String country;
  String nativeName;
  bool isRTL;
  Calendar calendar;

  Language({
    required this.id,
    required this.name,
    required this.code,
    required this.country,
    required this.nativeName,
    required this.isRTL,
    required this.calendar,
  });
}

enum Calendar {
  gregorian,
  solarJalali,
}
