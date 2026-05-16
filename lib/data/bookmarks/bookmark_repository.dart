import 'package:hive_ce_flutter/hive_flutter.dart';
import 'bookmark_model.dart';

class BookmarkRepository {
  static const _boxName = 'bookmarks';

  // Call this once at startup in main.dart
  static Future<void> init() async {
    Hive.registerAdapter(BookmarkModelAdapter());
    await Hive.openBox<BookmarkModel>(_boxName);
  }

  Box<BookmarkModel> get _box => Hive.box<BookmarkModel>(_boxName);

  List<BookmarkModel> getAll() {
    return _box.values.toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt)); // newest first
  }

  bool isBookmarked(int pageNumber) {
    return _box.containsKey('page_$pageNumber');
  }

  Future<void> add(BookmarkModel bookmark) async {
    await _box.put(bookmark.boxKey, bookmark);
  }

  Future<void> remove(int pageNumber) async {
    await _box.delete('page_$pageNumber');
  }

  Future<void> toggle({
    required int pageNumber,
    required String surahNameLatin,
    required String surahNameArabic,
    required String ayahRange,
    String? note,
  }) async {
    if (isBookmarked(pageNumber)) {
      await remove(pageNumber);
    } else {
      await add(
        BookmarkModel(
          pageNumber: pageNumber,
          surahNameLatin: surahNameLatin,
          surahNameArabic: surahNameArabic,
          ayahRange: ayahRange,
          savedAt: DateTime.now(),
          note: note,
        ),
      );
    }
  }

  // Watch for reactive UI updates
  Stream<BoxEvent> watch() => _box.watch();
}
