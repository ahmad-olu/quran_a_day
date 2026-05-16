part of 'audio_cubit.dart';

enum AudioStatus { idle, loading, playing, paused, stopped, error }

@immutable
class AudioState {
  const AudioState({
    this.status = AudioStatus.idle,
    this.currentSurah,
    this.currentAyah,
    this.currentIndex = 0,
    this.totalAyahs = 0,
    this.selectedQariSlug = 'Alafasy_128kbps',
    this.errorMessage,
    this.isRepeatOne = false,
  });

  final AudioStatus status;
  final int? currentSurah;
  final int? currentAyah;
  final int currentIndex;
  final int totalAyahs;
  final String selectedQariSlug;
  final String? errorMessage;
  final bool isRepeatOne; // loop single ayah for memorisation

  bool get isPlaying => status == AudioStatus.playing;
  bool get isLoading => status == AudioStatus.loading;

  AudioState copyWith({
    AudioStatus? status,
    int? currentSurah,
    int? currentAyah,
    int? currentIndex,
    int? totalAyahs,
    String? selectedQariSlug,
    String? errorMessage,
    bool? isRepeatOne,
  }) {
    return AudioState(
      status: status ?? this.status,
      currentSurah: currentSurah ?? this.currentSurah,
      currentAyah: currentAyah ?? this.currentAyah,
      currentIndex: currentIndex ?? this.currentIndex,
      totalAyahs: totalAyahs ?? this.totalAyahs,
      selectedQariSlug: selectedQariSlug ?? this.selectedQariSlug,
      errorMessage: errorMessage,
      isRepeatOne: isRepeatOne ?? this.isRepeatOne,
    );
  }
}
