// lib/app/widgets/audio_player_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_a_day/data/audio/quran_audio_repository.dart';
import 'package:quran_a_day/state/audio_cubit/audio_cubit.dart';

class AudioPlayerBar extends StatelessWidget {
  const AudioPlayerBar({
    super.key,
    required this.pageSegments,
  });

  // (surahNumber, startAyah, endAyah) — comes from RandomPageLoaded
  final List<(int, int, int)> pageSegments;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioCubit, AudioState>(
      builder: (context, state) {
        final cubit = context.read<AudioCubit>();
        final theme = Theme.of(context);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Qari selector
              _QariSelector(selectedSlug: state.selectedQariSlug),

              const SizedBox(height: 8),

              // Ayah progress indicator
              if (state.totalAyahs > 0)
                Text(
                  state.currentAyah != null
                      ? 'Surah ${state.currentSurah} — Ayah ${state.currentAyah} '
                          '(${state.currentIndex + 1}/${state.totalAyahs})'
                      : 'Ready',
                  style: theme.textTheme.bodySmall,
                ),

              const SizedBox(height: 4),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Repeat toggle
                  IconButton(
                    icon: Icon(
                      Icons.repeat_one,
                      color: state.isRepeatOne
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                    onPressed: cubit.toggleRepeatOne,
                    tooltip: 'Repeat ayah',
                  ),

                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: cubit.previous,
                  ),

                  // Main play/pause/loading button
                  _PlayPauseButton(
                    state: state,
                    onPlay: () => cubit.playPage(pageSegments: pageSegments),
                    onPause: cubit.pause,
                    onResume: cubit.resume,
                  ),

                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: cubit.next,
                  ),

                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: cubit.stop,
                    tooltip: 'Stop',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.state,
    required this.onPlay,
    required this.onPause,
    required this.onResume,
  });

  final AudioState state;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return IconButton.filled(
      iconSize: 32,
      icon: Icon(
        state.isPlaying ? Icons.pause : Icons.play_arrow,
      ),
      onPressed: switch (state.status) {
        AudioStatus.idle || AudioStatus.stopped => onPlay,
        AudioStatus.playing => onPause,
        AudioStatus.paused => onResume,
        _ => onPlay,
      },
    );
  }
}

class _QariSelector extends StatelessWidget {
  const _QariSelector({required this.selectedSlug});
  final String selectedSlug;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedSlug,
        isExpanded: true,
        items: QuranAudioRepository.availableQaris
            .map(
              (q) => DropdownMenuItem(
                value: q.slug,
                child: Text(q.name, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (slug) {
          if (slug != null) {
            context.read<AudioCubit>().changeQari(slug);
          }
        },
      ),
    );
  }
}
