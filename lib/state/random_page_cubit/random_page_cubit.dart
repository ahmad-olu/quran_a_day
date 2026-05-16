import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:lamsz_quran_api/lamsz_quran_api.dart';
import 'package:meta/meta.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';

part 'random_page_state.dart';

class RandomPageCubit extends Cubit<RandomPageState> {
  RandomPageCubit() : super(const RandomPageInitial());

  // Cache so we don't re-fetch the same surah in one session
  final Map<int, SurahContentModel> _surahCache = {};

  // Step 2 wired in here
  static const _lastPageKey = 'last_read_page';

  Future<SurahContentModel> _getCachedSurah(int surahNumber) async {
    if (_surahCache.containsKey(surahNumber)) {
      return _surahCache[surahNumber]!;
    }
    final data = await getSurahData(surahNumber: surahNumber);
    _surahCache[surahNumber] = data;
    return data;
  }

  Future<void> getRandomPage() async {
    emit(const RandomPageLoading());
    try {
      final random = Random();
      final pageNumber = 1 + random.nextInt(604);
      await _loadPage(pageNumber);
    } catch (e) {
      emit(RandomPageError(message: e.toString()));
    }
  }

  // Step 2 — resume last read page
  Future<void> getLastReadPage() async {
    emit(const RandomPageLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPage = prefs.getInt(_lastPageKey);
      if (lastPage == null) {
        await getRandomPage();
        return;
      }
      await _loadPage(lastPage);
    } catch (e) {
      emit(RandomPageError(message: e.toString()));
    }
  }

  Future<void> goToPage(int pageNumber) async {
    emit(const RandomPageLoading());
    try {
      await _loadPage(pageNumber);
    } catch (e) {
      emit(RandomPageError(message: e.toString()));
    }
  }

  Future<void> _loadPage(int pageNumber) async {
    // Save as last read
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPageKey, pageNumber);

    final pageData = quran.getPageData(pageNumber);

    // Get unique surah numbers to avoid duplicate fetches
    final uniqueSurahs = <int>{};
    for (final e in pageData) {
      final data = e as Map<String, int>;
      uniqueSurahs.add(data['surah']!);
    }

    // Fetch all unique surahs in parallel (not sequentially!)
    await Future.wait(
      uniqueSurahs.map((s) => _getCachedSurah(s)),
    );

    // Fetch surah name list once
    final surahList = await getSurahList();

    // Build ayah groups
    final ayahs = <(List<Aya>, String, String)>[];
    for (final e in pageData) {
      final data = e as Map<String, int>;
      final surahNum = data['surah']!;
      final start = data['start']!;
      final end = data['end']!;

      final surahContent = _surahCache[surahNum]!;
      final ayahSlice = surahContent.aya!.getRange(start - 1, end).toList();

      final surahInfo = surahList[surahNum];
      ayahs.add((
        ayahSlice,
        surahInfo.nameArabic ?? '',
        surahInfo.nameLatin ?? '',
      ));
    }

    emit(RandomPageLoaded(pageNumber: pageNumber, ayahs: ayahs));
  }
}
