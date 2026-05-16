part of 'daily_ayah_cubit.dart';

@immutable
sealed class DailyAyahState {
  const DailyAyahState();
}

final class DailyAyahInitial extends DailyAyahState {
  const DailyAyahInitial();
}

final class DailyAyahScheduled extends DailyAyahState {
  const DailyAyahScheduled({required this.isEnabled});
  final bool isEnabled;
}

final class DailyAyahError extends DailyAyahState {
  const DailyAyahError({required this.message});
  final String message;
}
