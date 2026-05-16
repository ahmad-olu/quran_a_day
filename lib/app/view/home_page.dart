import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_a_day/app/theme.dart';
import 'package:quran_a_day/app/view/bookmarks_page.dart';
import 'package:quran_a_day/app/view/get_q_uran_page.dart';
import 'package:quran_a_day/app/view/settings_page.dart';
import 'package:quran_a_day/app/widgets/geometric_pattern.dart';
import 'package:quran_a_day/app/widgets/gold_divider.dart';
import 'package:quran_a_day/app/widgets/hijri_date_chip.dart';
import 'package:quran_a_day/state/bookmark_cubit/bookmark_cubit.dart';
import 'package:quran_a_day/state/daily_ayah_cubit/daily_ayah_cubit.dart';
import 'package:quran_a_day/state/random_page_cubit/random_page_cubit.dart';
import 'package:responsive_builder/responsive_builder.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Animate in on first load
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );
    useEffect(() {
      controller.forward();
      return null;
    }, []);

    final fadeIn = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    final slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
      ),
    );

    return Scaffold(
      body: ResponsiveBuilder(
        builder: (context, sizing) {
          final isDesktop = sizing.deviceScreenType == DeviceScreenType.desktop;
          final isTablet = sizing.deviceScreenType == DeviceScreenType.tablet;
          final isLandscape =
              sizing.screenSize.width > sizing.screenSize.height;

          // Wide layout: split left panel + right panel
          if (isDesktop || (isTablet && isLandscape)) {
            return _WideLayout(
              fadeIn: fadeIn,
              slideUp: slideUp,
            );
          }

          // Portrait phone / tablet
          return _NarrowLayout(
            fadeIn: fadeIn,
            slideUp: slideUp,
          );
        },
      ),
    );
  }
}

// ── Narrow Layout (portrait phone) ──────────────────────────────────────────
class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.fadeIn,
    required this.slideUp,
  });

  final Animation<double> fadeIn;
  final Animation<Offset> slideUp;

  @override
  Widget build(BuildContext context) {
    return GeometricBackground(
      child: SafeArea(
        child: FadeTransition(
          opacity: fadeIn,
          child: SlideTransition(
            position: slideUp,
            child: Column(
              children: [
                _TopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const Gap(32),
                        _BismillahHeader(),
                        const Gap(20),
                        const HijriDateChip(),
                        const Gap(48),
                        _MainActionButton(),
                        const Gap(48),
                        const GoldDivider(),
                        const Gap(32),
                        _QuickActionsGrid(),
                        const Gap(32),
                        _LastReadBanner(),
                        const Gap(24),
                      ],
                    ),
                  ),
                ),
                _BottomNav(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Wide Layout (landscape / tablet / desktop) ───────────────────────────────
class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.fadeIn,
    required this.slideUp,
  });

  final Animation<double> fadeIn;
  final Animation<Offset> slideUp;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Row(
      children: [
        // Left panel — branding + main action
        SizedBox(
          width: size.width * 0.38,
          child: GeometricBackground(
            opacity: 0.12,
            child: Container(
              color: context.colors.primary.withValues(alpha: 0.97),
              child: SafeArea(
                child: FadeTransition(
                  opacity: fadeIn,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'بِسْمِ ٱللَّهِ',
                          style: const TextStyle(
                            fontFamily: 'Scheherazade New',
                            fontSize: 32,
                            color: AppColors.gold300,
                            height: 1.8,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          'Quran\na Day',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: AppColors.parchment100,
                            height: 1.1,
                          ),
                        ),
                        const Gap(16),
                        const HijriDateChip(),
                        const Spacer(),
                        _MainActionButton(light: true),
                        const Gap(32),
                        _LastReadBanner(compact: true),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Right panel — quick actions + bookmarks preview
        Expanded(
          child: SafeArea(
            child: FadeTransition(
              opacity: fadeIn,
              child: SlideTransition(
                position: slideUp,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopBar(showTitle: false),
                      const Gap(32),
                      _QuickActionsGrid(),
                      const Gap(32),
                      _BookmarksPreview(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Bismillah Header ─────────────────────────────────────────────────────────
class _BismillahHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Scheherazade New',
            fontSize: 26,
            color: context.goldColor,
            height: 2,
          ),
        ),
        const Gap(4),
        Text(
          'QURAN A DAY',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 4,
            color: context.subtleTextColor,
          ),
        ),
        const Gap(6),
        Text(
          'One page. Every day.',
          style: GoogleFonts.lora(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            color: context.textColor,
          ),
        ),
      ],
    );
  }
}

// ── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({this.showTitle = true});
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (showTitle)
            Expanded(
              child: Text(
                'Quran a Day',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.textColor,
                ),
              ),
            )
          else
            const Spacer(),

          // Settings
          IconButton(
            icon: Icon(Icons.tune_rounded, color: context.subtleTextColor),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<SettingsPage>(
                builder: (_) => const SettingsPage(),
              ),
            ),
          ),

          // Bookmarks
          BlocBuilder<BookmarkCubit, BookmarkState>(
            builder: (context, state) {
              final count =
                  state is BookmarkLoaded ? state.bookmarks.length : 0;
              return Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: IconButton(
                  icon: Icon(
                    Icons.bookmark_rounded,
                    color: context.goldColor,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<BookmarksPage>(
                      builder: (_) => const BookmarksPage(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Main Action Button ────────────────────────────────────────────────────────
class _MainActionButton extends StatelessWidget {
  const _MainActionButton({this.light = false});
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder<GetQUranPage>(
              pageBuilder: (_, anim, __) => FadeTransition(
                opacity: anim,
                child: const GetQUranPage(),
              ),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: light ? AppColors.gold400 : context.colors.primary,
              boxShadow: [
                BoxShadow(
                  color: context.goldColor.withValues(alpha: 0.35),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FlutterIslamicIcons.solidQuran,
                  size: 44,
                  color: light ? AppColors.navy900 : AppColors.gold200,
                ),
                const Gap(4),
                Text(
                  'READ',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: light ? AppColors.navy900 : AppColors.gold100,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(12),
        Text(
          'Tap for a random page',
          style: GoogleFonts.lora(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: light ? AppColors.parchment300 : context.subtleTextColor,
          ),
        ),
      ],
    );
  }
}

// ── Quick Actions Grid ────────────────────────────────────────────────────────
class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Each cell is half screen width minus padding and spacing
    final cellWidth =
        (screenWidth - 48 - 12) / 2; // 24px side padding × 2, 12px gap
    // Fix cell height at 68px — enough for icon + two text lines
    final ratio = cellWidth / 68;

    final actions = [
      _QuickAction(
        icon: Icons.search_rounded,
        label: 'Search',
        sublabel: 'Find an ayah |⚠️ in progress',
        //onTap: () {/* Step 7 */},
      ),
      _QuickAction(
        icon: Icons.notifications_outlined,
        label: 'Daily Ayah',
        sublabel: 'Notifications',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<SettingsPage>(
            builder: (_) => const SettingsPage(),
          ),
        ),
        trailing: BlocBuilder<DailyAyahCubit, DailyAyahState>(
          builder: (context, state) {
            final on = state is DailyAyahScheduled && state.isEnabled;
            return Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? AppColors.success : Colors.transparent,
              ),
            );
          },
        ),
      ),
      _QuickAction(
        icon: Icons.compass_calibration_outlined,
        label: 'Qibla',
        sublabel: 'Direction |⚠️ in progress',
        //onTap: () {/* future */},
      ),
      _QuickAction(
        icon: Icons.schedule_rounded,
        label: 'Prayer Times',
        sublabel: 'Today\'s salah |⚠️ in progress',
        //onTap: () {/* future */},
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.9,
      children: actions,
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.sublabel,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12, // ← was all(14), reduce horizontal
          vertical: 10, // ← explicit vertical, less than 14
        ),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.blueGrey : context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: context.colors.outline,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.colors.primary), // ← was 22
            const Gap(8), // ← was 10
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // ← ADD: don't stretch
                children: [
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.textColor,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: context.subtleTextColor,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

// ── Last Read Banner ──────────────────────────────────────────────────────────
class _LastReadBanner extends StatelessWidget {
  const _LastReadBanner({this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RandomPageCubit, RandomPageState>(
      builder: (context, state) {
        final pageNum = state is RandomPageLoaded ? state.pageNumber : null;
        if (pageNum == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            context.read<RandomPageCubit>().goToPage(pageNum);
            Navigator.push(
              context,
              MaterialPageRoute<GetQUranPage>(
                builder: (_) => const GetQUranPage(),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? 14 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.goldColor.withValues(alpha: 0.12),
                  context.goldColor.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: context.goldColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_stories_rounded,
                    color: context.goldColor, size: 20),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Continue Reading',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.goldColor,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Page $pageNum of 604',
                        style: GoogleFonts.lora(
                          fontSize: 14,
                          color: context.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: context.goldColor),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Bookmarks Preview (wide layout only) ─────────────────────────────────────
class _BookmarksPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarkCubit, BookmarkState>(
      builder: (context, state) {
        if (state is! BookmarkLoaded || state.bookmarks.isEmpty) {
          return const SizedBox.shrink();
        }
        final recent = state.bookmarks.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECENT BOOKMARKS',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: context.subtleTextColor,
              ),
            ),
            const Gap(12),
            ...recent.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  tileColor: context.surfaceColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: context.colors.outline),
                  ),
                  leading:
                      Icon(Icons.bookmark_rounded, color: context.goldColor),
                  title: Text(
                    b.surahNameLatin,
                    style: GoogleFonts.lora(fontSize: 14),
                  ),
                  subtitle: Text('Page ${b.pageNumber}',
                      style: GoogleFonts.outfit(fontSize: 12)),
                  trailing: Icon(Icons.arrow_forward_ios_rounded,
                      size: 13, color: context.subtleTextColor),
                  onTap: () {
                    context.read<RandomPageCubit>().goToPage(b.pageNumber);
                    Navigator.push(
                      context,
                      MaterialPageRoute<GetQUranPage>(
                        builder: (_) => const GetQUranPage(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Bottom Nav (narrow only) ──────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          top: BorderSide(color: context.colors.outline),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home_rounded),
              color: context.colors.primary,
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_outline_rounded),
              color: context.subtleTextColor,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<BookmarksPage>(
                  builder: (_) => const BookmarksPage(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              color: context.subtleTextColor,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<SettingsPage>(
                  builder: (_) => const SettingsPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
