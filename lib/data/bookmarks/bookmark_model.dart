import 'package:hive_ce/hive.dart';

part 'bookmark_model.g.dart';

@HiveType(typeId: 0)
class BookmarkModel extends HiveObject {
  BookmarkModel({
    required this.pageNumber,
    required this.surahNameLatin,
    required this.surahNameArabic,
    required this.ayahRange,
    required this.savedAt,
    this.note,
  });

  @HiveField(0)
  final int pageNumber;

  @HiveField(1)
  final String surahNameLatin;

  @HiveField(2)
  final String surahNameArabic;

  @HiveField(3)
  final String ayahRange; // e.g. "1–7"

  @HiveField(4)
  final DateTime savedAt;

  @HiveField(5)
  final String? note;

  // Unique key so we don't double-bookmark same page
  String get boxKey => 'page_$pageNumber';
}
