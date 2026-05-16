/// Quran audio CDN — these are free, public, no API key needed.
/// Base: https://everyayah.com/data/{qari_slug}/{surah_3digit}{ayah_3digit}.mp3
/// Example: Mishary surah 2 ayah 1:
/// https://everyayah.com/data/Alafasy_128kbps/002001.mp3

class QariOption {
  const QariOption({required this.name, required this.slug});
  final String name;
  final String slug;
}

class QuranAudioRepository {
  static const _baseUrl = 'https://everyayah.com/data';

  static const availableQaris = [
    QariOption(name: 'Mishary Alafasy', slug: 'Alafasy_128kbps'),
    QariOption(
        name: 'Abu Bakr Al-Shatri', slug: 'Abu_Bakr_Ash-Shaatree_128kbps'),
    QariOption(name: 'Hani Ar-Rifai', slug: 'Hani_Rifai_192kbps'),
    QariOption(
        name: 'Maher Al-Muaiqly', slug: 'MaherAlMuaiqlyRamadan1435_128kbps'),
    QariOption(name: 'Sudais', slug: 'Abdurrahmaan_As-Sudais_192kbps'),
  ];

  /// Builds a list of ayah audio URLs for a given surah range on a page.
  /// [surahNumber] 1–114, [startAyah] and [endAyah] are 1-based.
  List<String> getAyahUrls({
    required String qariSlug,
    required int surahNumber,
    required int startAyah,
    required int endAyah,
  }) {
    final surah = surahNumber.toString().padLeft(3, '0');
    return List.generate(
      endAyah - startAyah + 1,
      (i) {
        final ayah = (startAyah + i).toString().padLeft(3, '0');
        return '$_baseUrl/$qariSlug/$surah$ayah.mp3';
      },
    );
  }

  /// Builds the full playlist for an entire Quran page
  /// [pageSegments] is the list of (surahNumber, startAyah, endAyah)
  List<({String url, int surah, int ayah})> buildPagePlaylist({
    required String qariSlug,
    required List<(int, int, int)> pageSegments,
  }) {
    final playlist = <({String url, int surah, int ayah})>[];
    for (final segment in pageSegments) {
      final (surahNum, start, end) = segment;
      for (var i = start; i <= end; i++) {
        final surah = surahNum.toString().padLeft(3, '0');
        final ayah = i.toString().padLeft(3, '0');
        playlist.add((
          url: '$_baseUrl/$qariSlug/$surah$ayah.mp3',
          surah: surahNum,
          ayah: i,
        ));
      }
    }
    return playlist;
  }
}
