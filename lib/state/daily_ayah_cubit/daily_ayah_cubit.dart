import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran_a_day/data/notifications/daily_ayah_scheduler.dart';
import 'package:quran_a_day/data/notifications/notification_service.dart';
import 'package:universal_platform/universal_platform.dart';

part 'daily_ayah_state.dart';

class DailyAyahCubit extends Cubit<DailyAyahState> {
  DailyAyahCubit() : super(const DailyAyahInitial());

  static const _enabledKey = 'daily_ayah_enabled';
  static const _lastShownKey = 'daily_ayah_last_shown';

  /// Call on app start — restores toggle state and
  /// handles desktop one-per-day fallback
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_enabledKey) ?? false;
    emit(DailyAyahScheduled(isEnabled: isEnabled));

    if (!isEnabled) return;

    // Desktop fallback: show once per calendar day
    if (!_canBackground) {
      final lastShown = prefs.getString(_lastShownKey);
      final today = DateTime.now().toIso8601String().substring(0, 10);
      if (lastShown != today) {
        await DailyAyahScheduler.instance.scheduleDailyAyah();
        await prefs.setString(_lastShownKey, today);
      }
    }
  }

  Future<void> enable() async {
    try {
      await NotificationService.instance.init();
      await DailyAyahScheduler.instance.scheduleDailyAyah();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, true);
      emit(const DailyAyahScheduled(isEnabled: true));
    } catch (e) {
      emit(DailyAyahError(message: e.toString()));
    }
  }

  Future<void> disable() async {
    try {
      await DailyAyahScheduler.instance.cancelDailyAyah();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, false);
      emit(const DailyAyahScheduled(isEnabled: false));
    } catch (e) {
      emit(DailyAyahError(message: e.toString()));
    }
  }

  Future<void> toggle() async {
    final current = state;
    if (current is DailyAyahScheduled && current.isEnabled) {
      await disable();
    } else {
      await enable();
    }
  }

  bool get _canBackground {
    // Reuses same check as scheduler

    return UniversalPlatform.isAndroid || UniversalPlatform.isIOS;
  }
}
