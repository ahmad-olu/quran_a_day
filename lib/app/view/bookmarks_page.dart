import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_a_day/app/theme.dart';
import 'package:quran_a_day/app/view/get_q_uran_page.dart';
import 'package:quran_a_day/app/widgets/gold_divider.dart';
import 'package:quran_a_day/state/bookmark_cubit/bookmark_cubit.dart';
import 'package:quran_a_day/state/random_page_cubit/random_page_cubit.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarks',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocBuilder<BookmarkCubit, BookmarkState>(
        builder: (context, state) {
          if (state is! BookmarkLoaded || state.bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_outline_rounded,
                      size: 64, color: context.colors.outline),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarks yet',
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      color: context.subtleTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the bookmark icon while reading\nto save a page',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: context.subtleTextColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.bookmarks.length,
            separatorBuilder: (_, __) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: GoldDivider(width: 40),
            ),
            itemBuilder: (context, i) {
              final b = state.bookmarks[i];
              return _BookmarkTile(
                bookmark: b,
                onTap: () {
                  context.read<RandomPageCubit>().goToPage(b.pageNumber);
                  Navigator.push(
                    context,
                    MaterialPageRoute<GetQUranPage>(
                      builder: (_) => const GetQUranPage(),
                    ),
                  );
                },
                onDelete: () => context.read<BookmarkCubit>().toggle(
                      pageNumber: b.pageNumber,
                      surahNameLatin: b.surahNameLatin,
                      surahNameArabic: b.surahNameArabic,
                      ayahRange: b.ayahRange,
                    ),
              );
            },
          );
        },
      ),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  const _BookmarkTile({
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
  });

  final dynamic bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.outline),
        ),
        child: Row(
          children: [
            // Arabic name
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.goldColor.withValues(alpha: 0.12),
                border: Border.all(
                  color: context.goldColor.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  '${bookmark.pageNumber}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.goldColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookmark.surahNameLatin as String,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.textColor,
                    ),
                  ),
                  Text(
                    bookmark.surahNameArabic as String,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Scheherazade New',
                      fontSize: 18,
                      color: context.goldColor,
                      height: 1.6,
                    ),
                  ),
                  Text(
                    'Ayahs ${bookmark.ayahRange}  •  '
                    '${bookmark.savedAt.day}/${bookmark.savedAt.month}/${bookmark.savedAt.year}',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: context.subtleTextColor,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: context.colors.error, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
