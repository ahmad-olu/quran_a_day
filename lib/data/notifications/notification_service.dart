import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:universal_platform/universal_platform.dart';

/// Wraps flutter_local_notifications with full platform guards.
/// flutter_local_notifications supports: Android, iOS, Linux, Windows, macOS
/// Does NOT support: Web
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialised = false;

  // Notification channel constants
  static const _channelId = 'daily_ayah';
  static const _channelName = 'Daily Ayah';
  static const _channelDesc = 'Daily Quran ayah reminder';
  static const _notificationId = 1;

  /// Whether this platform supports local notifications at all
  static bool get isSupported {
    if (kIsWeb) return false; // Web uses different API entirely
    return true; // Android, iOS, Linux, Windows, macOS all supported
  }

  /// Callback set by main.dart — called when user taps a notification
  void Function(String? payload)? onNotificationTap;

  Future<void> init({
    void Function(String? payload)? onTap,
  }) async {
    if (!isSupported) return;
    if (_initialised) return;

    onNotificationTap = onTap;

    // Platform-specific init settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Linux settings — uses system notification icon name
    final linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open',
      defaultIcon: AssetsLinuxIcon('assets/icon/icon.png'),
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // windows uses default settings
    const windowsSettings = WindowsInitializationSettings(
      appName: 'Quran a Day',
      appUserModelId: 'com.yourname.quran_a_day',
      guid: 'a8b4c2d1-e5f6-7890-abcd-ef1234567890', // generate your own
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
      windows: windowsSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        onNotificationTap?.call(details.payload);
      },
    );

    // Request permissions per platform
    await _requestPermissions();

    _initialised = true;
  }

  Future<void> _requestPermissions() async {
    if (UniversalPlatform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
    }

    if (UniversalPlatform.isIOS || UniversalPlatform.isMacOS) {
      final darwin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await darwin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Linux and Windows don't require explicit permission requests
  }

  /// Show the daily ayah notification immediately.
  /// Called by workmanager on mobile, or directly on desktop/Linux.
  Future<void> showDailyAyahNotification({
    required String surahName,
    required String ayahText,
    required String payload,
  }) async {
    if (!isSupported || !_initialised) return;

    // Android-specific channel details
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''), // filled below
      playSound: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.normal,
    );

    const windowsDetails = WindowsNotificationDetails();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(
          '', // overridden below — workaround for const limitation
        ),
        playSound: true,
      ),
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
      windows: windowsDetails,
    );

    await _plugin.show(
      id: _notificationId,
      title: 'آية اليوم — $surahName', // "Ayah of the day"
      body: ayahText,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Cancel the daily ayah notification
  Future<void> cancelDailyAyah() async {
    if (!isSupported) return;
    await _plugin.cancel(id: _notificationId);
  }

  /// Check if app was launched from a notification tap
  Future<String?> getLaunchPayload() async {
    if (!isSupported) return null;
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details?.notificationResponse?.payload;
    }
    return null;
  }
}
