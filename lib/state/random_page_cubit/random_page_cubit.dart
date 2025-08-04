import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:lamsz_quran_api/lamsz_quran_api.dart';
import 'package:meta/meta.dart';
import 'package:quran/quran.dart' as quran;

part 'random_page_state.dart';

typedef SurahName = String;

class RandomPageCubit extends Cubit<RandomPageState> {
  RandomPageCubit() : super(const RandomPageInitial());

  Future<void> getRandomPage() async {
    final random = Random();
    final randomNumber =
        1 + random.nextInt(604); // Generates a random number between 1 and 200

    final q = quran.getPageData(randomNumber);
    final surahContent = await getSurahData(surahNumber: 2);
    final m = q.map((e) {
      final data = e as Map<String, int>;
      return ((data['surah']!), (data['start']!), (data['end']!));
    }).toList();

    final ayahs = <(List<Aya>, SurahName, SurahName)>[];

    for (final e in q) {
      final data = e as Map<String, int>;
      final a = ((data['surah']!), (data['start']!), (data['end']!));
      final s = await getSurahData(surahNumber: a.$1);
      final k = s.aya!.getRange(a.$2 - 1, a.$3).toList();
      final surahList = await getSurahList().then((e) => e[s.id ?? 0]);
      ayahs.add((k, surahList.nameArabic ?? '', surahList.nameLatin ?? ''));
    }
    emit(RandomPageLoaded(surah: m, surahContent: surahContent, ayahs: ayahs));
  }
}
