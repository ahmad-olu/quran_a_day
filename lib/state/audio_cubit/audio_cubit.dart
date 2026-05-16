import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meta/meta.dart';
import 'package:quran_a_day/data/audio/platform_audio_service.dart';
import 'package:quran_a_day/data/audio/quran_audio_repository.dart';

part 'audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  AudioCubit({required this.repository}) : super(const AudioState()) {
    _initPlayer();
  }

  final QuranAudioRepository repository;
  late final AudioPlayer _player;
  StreamSubscription<int?>? _indexSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  // Mirrors the playlist so we can look up surah/ayah by index
  List<({String url, int surah, int ayah})> _playlist = [];

  void _initPlayer() {
    _player = AudioPlayer();

    // Track which ayah is playing
    _indexSub = _player.currentIndexStream.listen((index) {
      if (index == null || index >= _playlist.length) return;
      final current = _playlist[index];
      emit(state.copyWith(
        currentIndex: index,
        currentSurah: current.surah,
        currentAyah: current.ayah,
      ));
    });

    // Track play/pause/stop
    _playerStateSub = _player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        emit(state.copyWith(status: AudioStatus.stopped));
      }
    });
  }

  /// Load a full page playlist and start playing
  Future<void> playPage({
    required List<(int, int, int)> pageSegments,
    String? qariSlug,
  }) async {
    emit(state.copyWith(status: AudioStatus.loading));
    try {
      final slug = qariSlug ?? state.selectedQariSlug;
      _playlist = repository.buildPagePlaylist(
        qariSlug: slug,
        pageSegments: pageSegments,
      );

      final audioSources =
          _playlist.map((e) => AudioSource.uri(Uri.parse(e.url))).toList();

      await _player.setAudioSource(
        ConcatenatingAudioSource(children: audioSources),
        preload: false, // important on Linux — avoids pre-buffering all files
      );

      // Set loop mode based on isRepeatOne
      await _player.setLoopMode(
        state.isRepeatOne ? LoopMode.one : LoopMode.off,
      );

      await _player.play();
      emit(state.copyWith(
        status: AudioStatus.playing,
        totalAyahs: _playlist.length,
        selectedQariSlug: slug,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AudioStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Play a single specific ayah (for memorisation mode)
  Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    String? qariSlug,
  }) async {
    await playPage(
      pageSegments: [(surahNumber, ayahNumber, ayahNumber)],
      qariSlug: qariSlug,
    );
  }

  Future<void> pause() async {
    await _player.pause();
    emit(state.copyWith(status: AudioStatus.paused));
  }

  Future<void> resume() async {
    await _player.play();
    emit(state.copyWith(status: AudioStatus.playing));
  }

  Future<void> stop() async {
    await _player.stop();
    emit(state.copyWith(status: AudioStatus.stopped));
  }

  Future<void> next() async {
    if (_player.hasNext) await _player.seekToNext();
  }

  Future<void> previous() async {
    if (_player.hasPrevious) await _player.seekToPrevious();
  }

  Future<void> seekToAyah(int index) async {
    await _player.seek(Duration.zero, index: index);
    await _player.play();
    emit(state.copyWith(status: AudioStatus.playing));
  }

  Future<void> toggleRepeatOne() async {
    final newRepeat = !state.isRepeatOne;
    await _player.setLoopMode(newRepeat ? LoopMode.one : LoopMode.off);
    emit(state.copyWith(isRepeatOne: newRepeat));
  }

  Future<void> changeQari(String slug) async {
    final wasPlaying = state.isPlaying;
    final currentIndex = state.currentIndex;
    emit(state.copyWith(selectedQariSlug: slug));

    // Rebuild playlist with new qari from same position
    if (_playlist.isNotEmpty) {
      final segments = <(int, int, int)>[];
      // Reconstruct segments from flat playlist — group by surah
      int? lastSurah;
      int? segStart;
      int? segEnd;
      for (final item in _playlist) {
        if (item.surah != lastSurah) {
          if (lastSurah != null) {
            segments.add((lastSurah, segStart!, segEnd!));
          }
          lastSurah = item.surah;
          segStart = item.ayah;
        }
        segEnd = item.ayah;
      }
      if (lastSurah != null) segments.add((lastSurah, segStart!, segEnd!));

      await playPage(pageSegments: segments, qariSlug: slug);

      // Resume from same ayah position
      await _player.seek(Duration.zero, index: currentIndex);
      if (!wasPlaying) await _player.pause();
    }
  }

  @override
  Future<void> close() async {
    await _indexSub?.cancel();
    await _playerStateSub?.cancel();
    await _player.dispose();
    return super.close();
  }
}
