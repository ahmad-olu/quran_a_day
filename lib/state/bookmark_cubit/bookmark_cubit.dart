import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:quran_a_day/data/bookmarks/bookmark_model.dart';
import 'package:quran_a_day/data/bookmarks/bookmark_repository.dart';

part 'bookmark_state.dart';

class BookmarkCubit extends Cubit<BookmarkState> {
  BookmarkCubit({required this.repository}) : super(const BookmarkInitial()) {
    _init();
  }

  final BookmarkRepository repository;
  StreamSubscription<dynamic>? _boxSubscription;

  void _init() {
    _load();
    // Reactively rebuild whenever the box changes
    _boxSubscription = repository.watch().listen((_) => _load());
  }

  void _load() {
    try {
      final bookmarks = repository.getAll();
      emit(BookmarkLoaded(bookmarks: bookmarks));
    } catch (e) {
      emit(BookmarkError(message: e.toString()));
    }
  }

  Future<void> toggle({
    required int pageNumber,
    required String surahNameLatin,
    required String surahNameArabic,
    required String ayahRange,
    String? note,
  }) async {
    try {
      await repository.toggle(
        pageNumber: pageNumber,
        surahNameLatin: surahNameLatin,
        surahNameArabic: surahNameArabic,
        ayahRange: ayahRange,
        note: note,
      );
    } catch (e) {
      emit(BookmarkError(message: e.toString()));
    }
  }

  bool isBookmarked(int pageNumber) => repository.isBookmarked(pageNumber);

  @override
  Future<void> close() {
    _boxSubscription?.cancel();
    return super.close();
  }
}
