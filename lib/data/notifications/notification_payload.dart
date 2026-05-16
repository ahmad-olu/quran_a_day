/// Typed payload passed through notifications so we can
/// navigate to the right page when user taps the notification.
class NotificationPayload {
  const NotificationPayload({
    required this.pageNumber,
    required this.surahNameLatin,
    required this.ayahText,
  });

  final int pageNumber;
  final String surahNameLatin;
  final String ayahText;

  // Simple manual serialisation — no json_serializable needed
  String toPayloadString() => '$pageNumber|$surahNameLatin|$ayahText';

  static NotificationPayload? fromPayloadString(String? raw) {
    if (raw == null) return null;
    final parts = raw.split('|');
    if (parts.length < 3) return null;
    return NotificationPayload(
      pageNumber: int.tryParse(parts[0]) ?? 1,
      surahNameLatin: parts[1],
      ayahText: parts.sublist(2).join('|'), // ayah text may contain |
    );
  }
}
