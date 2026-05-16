import 'package:flutter/foundation.dart';
import 'package:universal_platform/universal_platform.dart';

/// Centralised platform capability checks.
/// Add new checks here as we add more platform-sensitive features (Step 5 etc).
class PlatformAudioService {
  /// just_audio core playback — works everywhere
  static bool get canPlayAudio => true;

  /// audio_service (background/lock screen controls)
  /// NOT supported on Linux or Web
  static bool get canUseBackgroundAudio {
    if (kIsWeb) return false;
    if (UniversalPlatform.isLinux) return false;
    return true;
  }

  /// just_audio_background — mobile + Windows + macOS only
  static bool get canUseAudioBackground {
    if (kIsWeb) return false;
    if (UniversalPlatform.isLinux) return false;
    return true;
  }
}
