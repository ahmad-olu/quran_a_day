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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPageKey, pageNumber);

    final pageData = quran.getPageData(pageNumber);

    // FIXED: cast to Map<String, dynamic> not Map<String, int>
    final segments = pageData.map((e) {
      final data = e as Map<String, dynamic>;
      return (
        data['surah']! as int,
        data['start']! as int,
        data['end']! as int
      );
    }).toList();

    final uniqueSurahs = segments.map((s) => s.$1).toSet();

    await Future.wait(uniqueSurahs.map(_getCachedSurah));

    final surahList = await getSurahList();

    final ayahs = <(List<Aya>, String, String)>[];
    for (final seg in segments) {
      final surahContent = _surahCache[seg.$1]!;
      final slice = surahContent.aya!.getRange(seg.$2 - 1, seg.$3).toList();
      final info = surahList[seg.$1];
      ayahs.add((slice, info.nameArabic ?? '', info.nameLatin ?? ''));
    }

    emit(RandomPageLoaded(
      pageNumber: pageNumber,
      ayahs: ayahs,
      segments: segments,
    ));
  }
}
