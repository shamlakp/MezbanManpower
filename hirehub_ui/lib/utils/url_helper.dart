import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class UrlHelper {


  static String getBaseUrl() {
    if (kIsWeb) {
      if (kDebugMode) return 'http://127.0.0.1:8000';
      return 'https://shamlashammu.pythonanywhere.com';
    }
    if (defaultTargetPlatform == TargetPlatform.android && kDebugMode) {
      return 'http://10.0.2.2:8000';
    }
    if (kDebugMode) return 'http://127.0.0.1:8000';
    return 'https://shamlashammu.pythonanywhere.com';
  }


  static String resolveMediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    String baseUrl = getBaseUrl();
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    // If the API returns an absolute URL (e.g. http://127.0.0.1:8000/media/...),
    // DRF builds it from the incoming request host which is wrong for:
    //   - physical mobile devices in debug  (127.0.0.1 = the phone itself)
    //   - any environment where the host differs from the client
    // Fix: always strip the host and rebase to the correct server URL.
    if (path.startsWith('http://') || path.startsWith('https://')) {
      try {
        final uri = Uri.parse(path);
        // Keep the path + query but use our correct base URL
        final relativePart = uri.path +
            (uri.query.isNotEmpty ? '?${uri.query}' : '');
        return '$baseUrl$relativePart';
      } catch (_) {
        // If parsing fails just return the original URL as a fallback
        return path;
      }
    }

    // Relative path – just prepend the base URL
    final formattedPath = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$formattedPath';
  }

  static Future<void> launchBackendUrl(String path) async {
    final String fullUrl = '${getBaseUrl()}$path';
    final Uri uri = Uri.parse(fullUrl);
    
    try {
      debugPrint('Attempting to launch: $fullUrl');
      final bool success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!success) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e2) {
        debugPrint('Final attempt failed: $e2');
      }
    }
  }
}
