import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class UrlHelper {


  static String getBaseUrl() {
    if (kIsWeb) {
      if (kDebugMode) return 'http://localhost:8000';
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
    
    // Fix for Android emulator receiving localhost URLs from backend
    if (defaultTargetPlatform == TargetPlatform.android && kDebugMode) {
      if (path.startsWith('http://127.0.0.1')) {
        path = path.replaceFirst('127.0.0.1', '10.0.2.2');
      } else if (path.startsWith('http://localhost')) {
        path = path.replaceFirst('localhost', '10.0.2.2');
      }
    }

    if (path.startsWith('http')) return path;
    
    // Ensure it starts with /
    final formattedPath = path.startsWith('/') ? path : '/$path';
    
    String baseUrl = getBaseUrl();
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    
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
