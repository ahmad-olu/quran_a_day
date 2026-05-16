import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamsz_quran_api/model/surah_content_model.dart';
import 'package:quran_a_day/app/theme.dart';
import 'package:quran_a_day/app/widgets/audio_player_bar.dart';
import 'package:quran_a_day/app/widgets/geometric_pattern.dart';
import 'package:quran_a_day/app/widgets/gold_divider.dart';
import 'package:quran_a_day/state/audio_cubit/audio_cubit.dart';
import 'package:quran_a_day/state/bookmark_cubit/bookmark_cubit.dart';
import 'package:quran_a_day/state/random_page_cubit/random_page_cubit.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:quran/quran.dart' as quran;

class GetQUranPage extends StatelessWidget {
  const GetQUranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) => RandomPageCubit()..getRandomPage(),
      child: const _GetQuranView(),
    );
  }
}

class _GetQuranView extends StatelessWidget {
  const _GetQuranView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RandomPageCubit, RandomPageState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.colors.surface,
          appBar: _QuranAppBar(state: state),
          body: switch (state) {
            RandomPageInitial() => const _EmptyState(),
            RandomPageLoading() => const _LoadingState(),
            RandomPageError(:final message) => _ErrorState(message: message),
            RandomPageLoaded() => _LoadedView(state: state),
          },
        );
      },
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────
class _QuranAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _QuranAppBar({required this.state});
  final RandomPageState state;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isLoaded = state is RandomPageLoaded;
    final pageNum = isLoaded ? (state as RandomPageLoaded).pageNumber : null;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            pageNum != null ? 'Page $pageNum' : 'Quran',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (pageNum != null)
            Text(
              'of 604',
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: AppColors.parchment300,
              ),
            ),
        ],
      ),
      actions: [
        // Bookmark toggle
        if (isLoaded)
          BlocBuilder<BookmarkCubit, BookmarkState>(
            builder: (context, bmState) {
              final page = (state as RandomPageLoaded).pageNumber;
              final isBookmarked =
                  context.read<BookmarkCubit>().isBookmarked(page);
              return IconButton(
                icon: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color:
                      isBookmarked ? AppColors.gold400 : AppColors.parchment300,
                ),
                onPressed: () {
                  final loaded = state as RandomPageLoaded;
                  final first = loaded.ayahs.first;
                  context.read<BookmarkCubit>().toggle(
                        pageNumber: loaded.pageNumber,
                        surahNameLatin: first.$3,
                        surahNameArabic: first.$2,
                        ayahRange: '${first.$1.first.id}–${first.$1.last.id}',
                      );
                },
              );
            },
          ),

        // Refresh
        IconButton(
          icon: const Icon(Icons.shuffle_rounded),
          tooltip: 'Random page',
          onPressed: () => context.read<RandomPageCubit>().getRandomPage(),
        ),
      ],
    );
  }
}

// ── Loaded View ───────────────────────────────────────────────────────────────
class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.state});
  final RandomPageLoaded state;

  @override
  Widget build(BuildContext context) {
    // Build page segments for audio
    final segments = state.segments;

    return ResponsiveBuilder(
      builder: (context, sizing) {
        final isWide = sizing.deviceScreenType == DeviceScreenType.desktop ||
            (sizing.deviceScreenType == DeviceScreenType.tablet &&
                sizing.screenSize.width > sizing.screenSize.height);

        return Column(
          children: [
            Expanded(
              child: isWide
                  ? _WideReader(state: state)
                  : _NarrowReader(state: state),
            ),

            // Audio bar — always at bottom
            //FIXME (this doesnt work on linux)?   AudioPlayerBar(pageSegments: segments),
          ],
        );
      },
    );
  }
}

// ── Narrow Reader (phone portrait) ───────────────────────────────────────────
class _NarrowReader extends StatelessWidget {
  const _NarrowReader({required this.state});
  final RandomPageLoaded state;

  @override
  Widget build(BuildContext context) {
    return GeometricBackground(
      opacity: 0.04,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
        itemCount: state.ayahs.length,
        separatorBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: const GoldDivider(),
        ),
        itemBuilder: (context, i) => _SurahSection(
          ayahData: state.ayahs[i],
          pageNumber: state.pageNumber,
          surahNumber: state.segments[i].$1,
        ),
      ),
    );
  }
}

// ── Wide Reader (landscape / tablet / desktop) ───────────────────────────────
class _WideReader extends StatelessWidget {
  const _WideReader({required this.state});
  final RandomPageLoaded state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Surah index sidebar
        Container(
          width: 200,
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.04),
            border: Border(
              right: BorderSide(color: context.colors.outline),
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.ayahs.length,
            itemBuilder: (context, i) {
              final surah = state.ayahs[i];
              return ListTile(
                dense: true,
                title: Text(
                  surah.$3, // latin name
                  style: GoogleFonts.lora(fontSize: 13),
                ),
                subtitle: Text(
                  surah.$2, // arabic name
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Scheherazade New',
                    fontSize: 16,
                    color: context.goldColor,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            },
          ),
        ),

        // Main reading area
        Expanded(
          child: GeometricBackground(
            opacity: 0.03,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              itemCount: state.ayahs.length,
              separatorBuilder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: const GoldDivider(),
              ),
              itemBuilder: (context, i) => _SurahSection(
                ayahData: state.ayahs[i],
                pageNumber: state.pageNumber,
                surahNumber:
                    state.segments[i].$1, // ← surahNum from segment tuple
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Surah Section ─────────────────────────────────────────────────────────────
class _SurahSection extends StatelessWidget {
  const _SurahSection({
    required this.ayahData,
    required this.pageNumber,
    required this.surahNumber, // ← ADD
  });

  // (ayahs, arabicName, latinName)
  final (List<Aya>, String, String) ayahData;
  final int pageNumber;
  final int surahNumber; // ← ADD

  @override
  Widget build(BuildContext context) {
    final (ayahs, arabicName, latinName) = ayahData;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Surah header
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.primary.withValues(alpha: 0.08),
                  context.colors.primary.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.goldColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Arabic name
                Text(
                  arabicName,
                  style: TextStyle(
                    fontFamily: 'Scheherazade New',
                    fontSize: 22,
                    color: context.goldColor,
                    height: 1.8,
                  ),
                ),
                // Latin name — flip direction for LTR text
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        latinName,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Bismillah
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                style: TextStyle(
                  fontFamily: 'Scheherazade New',
                  fontSize: 22,
                  color: context.goldColor,
                  height: 2,
                ),
              ),
            ),
          ),

          // Ayahs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _AyahsText(ayahs: ayahs, surahNumber: surahNumber),
          ),
        ],
      ),
    );
  }
}

// ── Ayahs RichText ────────────────────────────────────────────────────────────

class _AyahsText extends StatelessWidget {
  const _AyahsText({
    required this.ayahs,
    required this.surahNumber, // needed for audio highlight matching
  });

  final List<Aya> ayahs; // FIXED: was List<dynamic>
  final int surahNumber;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioCubit, AudioState>(
      builder: (ctx, audioState) {
        return RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            children: ayahs.asMap().entries.map((entry) {
              final index = entry.key; // 0-based index in slice
              final ayah = entry.value; // Aya object

              // ayah.id is the ayah number within the surah (int)
              final ayahNumber = ayah.id ?? (index + 1);

              // Match against audio state using surah + ayah number
              final isPlaying = audioState.isPlaying &&
                  audioState.currentSurah == surahNumber &&
                  audioState.currentAyah == ayahNumber;

              // Arabic numeral for display — use arabic_index if available,
              // else fall back to quran package's getVerseEndSymbol
              final arabicNumeral = ayah.arabicIndex ??
                  quran.getVerseEndSymbol(ayahNumber, arabicNumeral: true);

              return TextSpan(
                children: [
                  TextSpan(
                    text: '${ayah.arabic} ',
                    style: TextStyle(
                      fontFamily: 'Scheherazade New',
                      fontSize: 28,
                      height: 2.4,
                      color: isPlaying ? context.goldColor : context.textColor,
                      backgroundColor: isPlaying
                          ? context.goldColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: _AyahNumberBadge(
                      number: arabicNumeral, // FIXED: now typed String
                      isPlaying: isPlaying,
                    ),
                  ),
                  const TextSpan(text: ' '),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _AyahNumberBadge extends StatelessWidget {
  const _AyahNumberBadge({
    required this.number,
    required this.isPlaying,
  });

  final String number;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPlaying
            ? context.goldColor
            : context.goldColor.withValues(alpha: 0.15),
        border: Border.all(
          color: context.goldColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          number,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'Scheherazade New',
            fontSize: 11,
            color: isPlaying ? AppColors.navy900 : context.goldColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ── Loading / Empty / Error States ───────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: context.goldColor,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Opening the Quran...',
            style: GoogleFonts.lora(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: context.subtleTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Tap shuffle to begin',
        style: GoogleFonts.lora(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: context.subtleTextColor,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                color: context.colors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Could not load page',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(
                fontSize: 13,
                color: context.subtleTextColor,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.read<RandomPageCubit>().getRandomPage(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
