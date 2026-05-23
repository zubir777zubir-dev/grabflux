enum Platform { youtube, tiktok, instagram }
enum Format { mp4, mp3 }
enum Quality { q2160, q1080, q720, q480, q360 }

extension PlatformExt on Platform {
  String get label {
    switch (this) {
      case Platform.youtube: return 'YouTube';
      case Platform.tiktok: return 'TikTok';
      case Platform.instagram: return 'Instagram';
    }
  }

  String get placeholder {
    switch (this) {
      case Platform.youtube: return 'https://youtube.com/watch?v=...';
      case Platform.tiktok: return 'https://tiktok.com/@user/video/...';
      case Platform.instagram: return 'https://instagram.com/p/...';
    }
  }

  bool validateUrl(String url) {
    switch (this) {
      case Platform.youtube:
        return url.contains('youtube.com/watch') || url.contains('youtu.be');
      case Platform.tiktok:
        return url.contains('tiktok.com');
      case Platform.instagram:
        return url.contains('instagram.com');
    }
  }

  Color get color {
    switch (this) {
      case Platform.youtube: return const Color(0xFFFF3B3B);
      case Platform.tiktok: return const Color(0xFF00F2EA);
      case Platform.instagram: return const Color(0xFFE1306C);
    }
  }

  String get icon {
    switch (this) {
      case Platform.youtube: return '▶';
      case Platform.tiktok: return '♪';
      case Platform.instagram: return '◈';
    }
  }
}

extension QualityExt on Quality {
  String get label {
    switch (this) {
      case Quality.q2160: return '4K';
      case Quality.q1080: return '1080p';
      case Quality.q720: return '720p';
      case Quality.q480: return '480p';
      case Quality.q360: return '360p';
    }
  }

  String get value {
    switch (this) {
      case Quality.q2160: return '2160';
      case Quality.q1080: return '1080';
      case Quality.q720: return '720';
      case Quality.q480: return '480';
      case Quality.q360: return '360';
    }
  }
}

class DownloadRequest {
  final String url;
  final Platform platform;
  final Format format;
  final Quality quality;

  DownloadRequest({
    required this.url,
    required this.platform,
    required this.format,
    required this.quality,
  });
}
