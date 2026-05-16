part of 'random_page_cubit.dart';

typedef SurahRange = ({int surah, int start, int end});

@immutable
sealed class RandomPageState {
  const RandomPageState();
}

final class RandomPageInitial extends RandomPageState {
  const RandomPageInitial();
}

final class RandomPageLoading extends RandomPageState {
  const RandomPageLoading();
}

final class RandomPageLoaded extends RandomPageState {
  const RandomPageLoaded({
    required this.pageNumber,
    required this.ayahs,
  });

  final int pageNumber;
  final List<(List<Aya>, String, String)> ayahs;
}

final class RandomPageError extends RandomPageState {
  const RandomPageError({required this.message});
  final String message;
}
