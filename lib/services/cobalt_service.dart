import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/download_model.dart';

class CobaltService {
  static const String _baseUrl = 'https://api.cobalt.tools';

  static Future<CobaltResult> fetchDownloadUrl(DownloadRequest req) async {
    try {
      final body = {
        'url': req.url,
        'videoQuality': req.format == Format.mp3 ? '0' : req.quality.value,
        'audioFormat': 'mp3',
        'filenameStyle': 'pretty',
        'downloadMode': req.format == Format.mp3 ? 'audio' : 'auto',
        'twitterGif': false,
        'youtubeVideoCodec': 'h264',
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'];

        if (status == 'stream' || status == 'redirect') {
          return CobaltResult(
            success: true,
            downloadUrl: data['url'],
            filename: data['filename'] ?? _buildFilename(req),
          );
        } else if (status == 'picker') {
          // For Instagram/TikTok with multiple media
          final items = data['picker'] as List;
          if (items.isNotEmpty) {
            return CobaltResult(
              success: true,
              downloadUrl: items[0]['url'],
              filename: _buildFilename(req),
              pickerItems: items
                  .map((i) => PickerItem(
                        url: i['url'],
                        thumb: i['thumb'] ?? '',
                      ))
                  .toList(),
            );
          }
        } else if (status == 'error') {
          return CobaltResult(
            success: false,
            error: data['error']?['code'] ?? 'خطأ غير معروف',
          );
        }
      }

      return CobaltResult(
        success: false,
        error: 'فشل الاتصال بالخادم (${response.statusCode})',
      );
    } catch (e) {
      return CobaltResult(
        success: false,
        error: 'تعذّر الاتصال: تأكد من اتصالك بالإنترنت',
      );
    }
  }

  static String _buildFilename(DownloadRequest req) {
    final ext = req.format == Format.mp3 ? 'mp3' : 'mp4';
    final q = req.format == Format.mp3 ? '' : '_${req.quality.value}p';
    return '${req.platform.label.toLowerCase()}$q.$ext';
  }
}

class CobaltResult {
  final bool success;
  final String? downloadUrl;
  final String? filename;
  final String? error;
  final List<PickerItem>? pickerItems;

  CobaltResult({
    required this.success,
    this.downloadUrl,
    this.filename,
    this.error,
    this.pickerItems,
  });
}

class PickerItem {
  final String url;
  final String thumb;
  PickerItem({required this.url, required this.thumb});
}
