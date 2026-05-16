import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_a_day/app/theme.dart';
import 'package:quran_a_day/app/widgets/gold_divider.dart';
import 'package:quran_a_day/state/daily_ayah_cubit/daily_ayah_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader('Notifications'),
          const SizedBox(height: 12),
          _DailyAyahTile(),
          const SizedBox(height: 32),
          const GoldDivider(),
          const SizedBox(height: 32),
          _SectionHeader('About'),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.info_outline_rounded,
            title: 'Version',
            subtitle: '3.0.3',
          ),
          _InfoTile(
            icon: Icons.mosque_outlined,
            title: 'Quran Source',
            subtitle: 'Uthmanic Hafs via lamsz_quran_api',
          ),
          _InfoTile(
            icon: Icons.music_note_outlined,
            title: 'Audio Source',
            subtitle: 'everyayah.com — free public CDN',
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
        color: context.subtleTextColor,
      ),
    );
  }
}

class _DailyAyahTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DailyAyahCubit, DailyAyahState>(
      builder: (context, state) {
        final isOn = state is DailyAyahScheduled && state.isEnabled;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.colors.outline),
          ),
          child: Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: isOn ? context.goldColor : context.subtleTextColor,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Ayah',
                      style: GoogleFonts.lora(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.textColor,
                      ),
                    ),
                    Text(
                      isOn
                          ? 'You\'ll receive a daily ayah reminder'
                          : 'Get a random ayah notification each day',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: context.subtleTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isOn,
                activeColor: context.goldColor,
                onChanged: (_) => context.read<DailyAyahCubit>().toggle(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.subtleTextColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: context.subtleTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
