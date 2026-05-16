import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:lamsz_quran_api/lamsz_quran_api.dart';
import 'package:quran/quran.dart' as quran;
import 'package:universal_platform/universal_platform.dart';
import 'package:workmanager/workmanager.dart';
import 'notification_payload.dart';
import 'notification_service.dart';

/// workmanager task name — must be unique
const _taskName = 'daily_ayah_task';
const _taskUniqueName = 'daily_ayah_unique';

/// Whether this platform supports workmanager background scheduling
bool get _canUseWorkmanager {
  if (kIsWeb) return false;
  // workmanager only works on Android and iOS
  return UniversalPlatform.isAndroid || UniversalPlatform.isIOS;
}

/// Top-level function required by workmanager —
/// MUST be a top-level function (not a class method)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == _taskName) {
      await _fireRandomAyahNotification();
    }
    return true;
  });
}

/// The actual notification logic — shared between workmanager
/// background execution and foreground (desktop/Linux) fallback
Future<void> _fireRandomAyahNotification() async {
  try {
    final random = Random();
    final pageNumber = 1 + random.nextInt(604);
    final pageData = quran.getPageData(pageNumber);
    if (pageData.isEmpty) return;

    // Pick first segment on this page
    final first = pageData.first as Map<String, int>;
    final surahNum = first['surah']!;
    final ayahNum = first['start']!;

    final surahContent = await getSurahData(surahNumber: surahNum);
    final ayah = surahContent.aya?[ayahNum - 1];
    if (ayah == null) return;

    final surahList = await getSurahList();
    final surahName = surahList[surahNum].nameLatin ?? 'Surah $surahNum';

    final payload = NotificationPayload(
      pageNumber: pageNumber,
      surahNameLatin: surahName,
      ayahText: ayah.arabic ?? '',
    );

    await NotificationService.instance.showDailyAyahNotification(
      surahName: surahName,
      ayahText: ayah.arabic ?? '',
      payload: payload.toPayloadString(),
    );
  } catch (e) {
    debugPrint('Daily ayah notification error: $e');
  }
}

class DailyAyahScheduler {
  DailyAyahScheduler._();
  static final instance = DailyAyahScheduler._();

  /// Schedule daily background notification.
  /// On mobile: uses workmanager (true background).
  /// On Linux/Windows/macOS: fires immediately on app open as a fallback
  /// (can't background schedule without a system daemon).
  Future<void> scheduleDailyAyah() async {
    if (_canUseWorkmanager) {
      await _scheduleMobile();
    } else {
      // Desktop fallback — show notification on app open
      // In Step 6 we'll also offer a "Show today's ayah" button
      await _fireDesktopFallback();
    }
  }

  Future<void> _scheduleMobile() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    await Workmanager().registerPeriodicTask(
      _taskUniqueName,
      _taskName,
      // Minimum period workmanager allows is 15 minutes.
      // Android batches these — exact time not guaranteed,
      // but once-a-day is reliable.
      frequency: const Duration(hours: 24),
      initialDelay: _timeUntilFajr(), // start near Fajr time
      constraints: Constraints(
        networkType: NetworkType.connected, // needs network for API call
        requiresBatteryNotLow: false,
      ),
      existingWorkPolicy:
          ExistingPeriodicWorkPolicy.keep, // don't reschedule if exists
    );
  }

  Future<void> _fireDesktopFallback() async {
    // On Linux/Windows/macOS, just show on app open once per day.
    // We track last shown date in SharedPreferences (wired in cubit below).
    await _fireRandomAyahNotification();
  }

  Future<void> cancelDailyAyah() async {
    if (_canUseWorkmanager) {
      await Workmanager().cancelByUniqueName(_taskUniqueName);
    }
    await NotificationService.instance.cancelDailyAyah();
  }

  /// Calculate delay until next Fajr-ish time (5:00 AM)
  /// A rough heuristic — proper Fajr time uses adhan package (Step 6)
  Duration _timeUntilFajr() {
    final now = DateTime.now();
    var fajr = DateTime(now.year, now.month, now.day, 5);
    if (fajr.isBefore(now)) {
      fajr = fajr.add(const Duration(days: 1));
    }
    return fajr.difference(now);
  }
}
