import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/platform_settings.dart';
class PlatformProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  PlatformSettings? _settings;
  PlatformSettings? get settings => _settings;
  bool _isLoading = false;

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> fetchSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getPlatformSettings();
      if (response.statusCode == 200) {
        _settings = PlatformSettings.fromJson(response.data);
        if (kDebugMode) {
          debugPrint('fetchSettings: Platform settings retrieved successfully');
        }
      }
    } catch (e) {
      debugPrint('Error fetching platform settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
