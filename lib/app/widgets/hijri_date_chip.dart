import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:quran_a_day/app/theme.dart';

class HijriDateChip extends StatelessWidget {
  const HijriDateChip({super.key});

  @override
  Widget build(BuildContext context) {
    final today = HijriCalendar.now();
    final label = '${today.hDay} ${today.longMonthName} ${today.hYear} AH';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: context.goldColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
        color: context.goldColor.withValues(alpha: 0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded,
              size: 13, color: context.goldColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.goldColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
