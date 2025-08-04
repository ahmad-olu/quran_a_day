part of 'random_page_cubit.dart';

typedef SurahType = ({
  int surah,
  int start,
  int end,
});

@immutable
sealed class RandomPageState {
  const RandomPageState({
    required this.surah,
    required this.surahContent,
    required this.ayahs,
  });

  final List<(int, int, int)> surah;
  final SurahContentModel? surahContent;
  final List<(List<Aya>, SurahName, SurahName)> ayahs;
}

final class RandomPageInitial extends RandomPageState {
  const RandomPageInitial({
    super.surah = const [],
    super.surahContent,
    super.ayahs = const [],
  });
}

final class RandomPageLoaded extends RandomPageState {
  const RandomPageLoaded({
    required super.surah,
    required super.surahContent,
    required super.ayahs,
  });
}
